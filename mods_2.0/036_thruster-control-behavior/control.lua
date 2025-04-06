require("scripts.helpers")

local Handler = {}

local thruster_pairs = {
  {
    thruster = "thruster",
    power_switch = "thruster-control-behavior",
  },
  {
    thruster = "fusion-thruster",
    power_switch = "fusion-thruster-control-behavior",
  },
  {
    thruster = "ion-thruster",
    power_switch = "ion-thruster-control-behavior",
  },
}

local is_thruster = {}
local is_power_switch = {}

local power_switch_name_to_thruster_name = {}
local thruster_name_to_power_switch_name = {}

local on_created_entity_filters = {}

for _, thruster_pair in ipairs(thruster_pairs) do
  is_thruster[thruster_pair.thruster] = true
  is_power_switch[thruster_pair.power_switch] = true

  power_switch_name_to_thruster_name[thruster_pair.power_switch] = thruster_pair.thruster
  thruster_name_to_power_switch_name[thruster_pair.thruster] = thruster_pair.power_switch

  table.insert(on_created_entity_filters, {filter = "name"      , name = thruster_pair.thruster})
  table.insert(on_created_entity_filters, {filter = "ghost_name", name = thruster_pair.thruster})
  table.insert(on_created_entity_filters, {filter = "name"      , name = thruster_pair.power_switch})
  table.insert(on_created_entity_filters, {filter = "ghost_name", name = thruster_pair.power_switch})
end

local function get_entity_type(entity)
  return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end


local function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

local function create_struct()
  storage.index = storage.index + 1
  storage.structs[storage.index] = {
    id = storage.index,

    surface = nil,
    position = nil,

    thruster = nil,
    thruster_name = nil,
    power_switch = nil,
    power_switch_name = nil,

    inserter = nil,
    inserter_offering = {valid = false},
  }
  return storage.structs[storage.index]
end

local function struct_set_thruster(struct, thruster)
  assert(thruster)
  assert(thruster.valid)

  struct.thruster = thruster
  struct.thruster_name = get_entity_name(thruster)

  storage.deathrattles[script.register_on_object_destroyed(thruster)] = {type = "thruster", struct_id = struct.id}
  storage.unit_number_to_struct_id[thruster.unit_number] = struct.id
end

local function struct_set_power_switch(struct, power_switch)
  assert(power_switch)
  assert(power_switch.valid)

  struct.power_switch = power_switch
  struct.power_switch_name = get_entity_name(power_switch)

  storage.deathrattles[script.register_on_object_destroyed(power_switch)] = {type = "power-switch", struct_id = struct.id}
  storage.unit_number_to_struct_id[power_switch.unit_number] = struct.id
end

local function get_control_behavior_position(thruster)
  local entity_name = get_entity_name(thruster)

  if entity_name == "thruster" then
    return {thruster.position.x - 1.5, thruster.position.y - 1.0}
  elseif entity_name == "fusion-thruster" then
    return {thruster.position.x - 1.5, thruster.position.y + 1.0}
  elseif entity_name == "ion-thruster" then
    return {thruster.position.x - 1.5, thruster.position.y - 1.0}
  else
    error(string.format("no control behavior position known for %s.", entity_name))
  end
end

local function get_or_create_inserter_offering(struct)
  if not struct.inserter_offering.valid then
    struct.inserter_offering = game.surfaces["thruster-control-behavior"].create_entity{
      name = "item-on-ground",
      force = "neutral",
      position = {-0.5 + struct.id, -2.5},
      stack = {name = "wood"},
    }
    storage.deathrattles[script.register_on_object_destroyed(struct.inserter_offering)] = {type = "offering", struct_id = struct.id}
  end
end

local function set_thruster_state(thruster, active)
  if active == true then
    thruster.active = true
    thruster.custom_status = nil
  else
    thruster.active = false
    thruster.custom_status = {
      diode = defines.entity_status_diode.red,
      label = {"entity-status.disabled-by-control-behavior"},
    }
  end
end

local function invert_condition(condition)
  if condition.comparator == "=" then
    condition.comparator = "≠"
  elseif condition.comparator == "≠" then
    condition.comparator = "="
  elseif condition.comparator == ">" then
    condition.comparator = "≤"
  elseif condition.comparator == "≤" then
    condition.comparator = ">"
  elseif condition.comparator == "<" then
    condition.comparator = "≥"
  elseif condition.comparator == "≥" then
    condition.comparator = "<"
  else
    error(serpent.block(condition))
  end

  return condition
end

function Handler.on_init()
  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}

  storage.unit_number_to_struct_id = {}

  local mod_surface = game.planets["thruster-control-behavior"].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.migration_structs_store_entity_names = true

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "thruster"}) do
      if is_thruster[entity.name] then
        Handler.on_created_entity({entity = entity})
      end
    end
  end

  if script.active_mods["creative-space-platform-hub"] then
    remote.call("creative-space-platform-hub", "blacklist", "thruster-control-behavior")
  end
end

script.on_init(Handler.on_init)

script.on_configuration_changed(function(event)
  if storage.migration_structs_store_entity_names == nil then
    storage.migration_structs_store_entity_names = true
    for _, struct in pairs(storage.structs) do
      assert(struct.thruster_name == nil)
      struct.thruster_name = "thruster"
      assert(struct.power_switch_name == nil)
      struct.power_switch_name = "thruster-control-behavior"
    end
  end

  if script.active_mods["creative-space-platform-hub"] then
    remote.call("creative-space-platform-hub", "blacklist", "thruster-control-behavior")
  end
end)

local function on_created_thruster(entity)
  local power_switch_name = thruster_name_to_power_switch_name[get_entity_name(entity)]
  local power_switch_position = get_control_behavior_position(entity)
  local power_switch = surface_find_entity_or_ghost(entity.surface, power_switch_position, power_switch_name)
  if power_switch == nil then
    if entity.type == "entity-ghost" then
      power_switch = entity.surface.create_entity{
        name = "entity-ghost",
        ghost_name = power_switch_name,
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.minable = false
    else
      power_switch = entity.surface.create_entity{
        name = power_switch_name,
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.destructible = false
    end
    power_switch.power_switch_state = true
  end

  local struct_id = storage.unit_number_to_struct_id[power_switch.unit_number]
  local struct = struct_id and assert(storage.structs[struct_id]) or create_struct()

  struct.surface = entity.surface
  struct.position = entity.position
  struct_set_thruster(struct, entity)
  struct_set_power_switch(struct, power_switch)

  if struct.inserter == nil then
    local mod_surface = game.surfaces["thruster-control-behavior"]
    struct.inserter = mod_surface.create_entity{
      name = "inserter",
      force = "neutral",
      position = {-0.5 + struct.id, -1.5},
    }

    local inserter_red   = struct.inserter.get_wire_connector(defines.wire_connector_id.circuit_red  , true)
    local inserter_green = struct.inserter.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    assert(power_switch.get_wire_connector(defines.wire_connector_id.circuit_red  , true).connect_to(inserter_red  , false))
    assert(power_switch.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(inserter_green, false))

    local inserter_cb = struct.inserter.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
    inserter_cb.circuit_enable_disable = true
  end

  Handler.on_power_switch_touched(power_switch)
end

local function on_created_thruster_control_behavior(entity)
  local thruster_name = power_switch_name_to_thruster_name[get_entity_name(entity)]
  local thruster = surface_find_entity_or_ghost(entity.surface, entity.position, thruster_name)
  if thruster == nil then return entity.destroy() end

  local cb_position = get_control_behavior_position(thruster)
  if entity.position.x ~= cb_position[1] or entity.position.y ~= cb_position[2] then return entity.destroy() end

  assert(entity.quality.name == "normal") -- why would you even place a higher quality circuit connector manually?
  if entity.type == "entity-ghost" then entity.minable = false end
end


function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  local entity_type = get_entity_type(entity)

  if entity_type == "thruster" then return on_created_thruster(entity) end
  if entity_type == "power-switch" then return on_created_thruster_control_behavior(entity) end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, on_created_entity_filters)
end

local function destroy_struct(struct)
  struct.inserter.destroy()
  struct.inserter_offering.destroy()
  struct.power_switch.destroy()
  storage.structs[struct.id] = nil
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    storage.unit_number_to_struct_id[event.useful_id] = nil

    if deathrattle.type == "thruster" then
      local struct = assert(storage.structs[deathrattle.struct_id])
      if struct.surface.valid == false then return destroy_struct(struct) end
      local new_thruster = surface_find_entity_or_ghost(struct.surface, struct.position, struct.thruster_name)
      if new_thruster then
        struct_set_thruster(struct, new_thruster)

        if new_thruster.type == "entity-ghost" and struct.power_switch.type ~= "entity-ghost" then
          struct.power_switch.destructible = true
          assert(struct.power_switch.die(struct.power_switch.force))
          struct_set_power_switch(struct, surface_find_entity_or_ghost(struct.surface, get_control_behavior_position(new_thruster), struct.power_switch_name))
          struct.power_switch.minable = false
        elseif new_thruster.type ~= "entity-ghost" and struct.power_switch.type == "entity-ghost" then
          struct.power_switch.destructible = true
          local _, new_power_switch = struct.power_switch.revive{}
          struct_set_power_switch(struct, new_power_switch)
          struct.power_switch.destructible = false
        end
      else
        destroy_struct(struct)
      end
    end

    if deathrattle.type == "offering" then
      -- game.print("offering reset at " .. event.tick)
      local struct = storage.structs[deathrattle.struct_id]
      if struct then
        struct.inserter.held_stack.clear()
        if struct.power_switch.valid then
          Handler.on_power_switch_touched(struct.power_switch)
        end
      end
    end

  end
end)

-- we trigger this event when a power switch has likely received new settings,
-- it is no guarantee since blueprints can also configure them,
-- and we also won't listen to open gui's every tick.
function Handler.on_power_switch_touched(entity)
  local struct_id = storage.unit_number_to_struct_id[entity.unit_number]
  assert(struct_id)
  local struct = storage.structs[struct_id]
  assert(struct)

  if struct.thruster.valid == false then return end

  local inserter_cb = struct.inserter.get_control_behavior()
  local power_switch_cb = struct.power_switch.get_control_behavior()

  -- match the circuit condition of the power switch with the inserter, but if the checkbox is off: clear the inserter condition
  if power_switch_cb.circuit_enable_disable then
    inserter_cb.circuit_condition = entity.power_switch_state and invert_condition(power_switch_cb.circuit_condition) or power_switch_cb.circuit_condition
    set_thruster_state(struct.thruster, entity.power_switch_state)
  else
    inserter_cb.circuit_condition = nil
    set_thruster_state(struct.thruster, struct.power_switch.power_switch_state)
  end

  get_or_create_inserter_offering(struct)

  -- game.print(serpent.line( struct.power_switch.get_or_create_control_behavior().circuit_condition ))
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.last_entity

  if entity and is_power_switch[get_entity_name(entity)] then
    Handler.on_power_switch_touched(entity)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  if entity and is_power_switch[get_entity_name(entity)] then
    Handler.on_power_switch_touched(entity)
  end
end)

local function get_power_switch_from_thruster(thruster)
  return storage.structs[storage.unit_number_to_struct_id[thruster.unit_number]].power_switch
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local entity = event.destination

  if is_power_switch[get_entity_name(entity)] then
    Handler.on_power_switch_touched(entity)
  elseif is_thruster[get_entity_name(entity)] and is_thruster[get_entity_name(event.source)] then
    -- support copying thruster onto truster too, so players are not required to always copy the control behavior
    local old_power_switch = get_power_switch_from_thruster(event.source)
    local new_power_switch = get_power_switch_from_thruster(entity)
    new_power_switch.copy_settings(old_power_switch, event.player_index)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and is_power_switch[entity.name] then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    local footer = player.gui.relative["thruster-control-behavior-footer"]
    if footer then footer.destroy() end

    footer = player.gui.relative.add{
      type = "frame",
      name = "thruster-control-behavior-footer",
      anchor = {
        gui = defines.relative_gui_type.power_switch_gui,
        position = defines.relative_gui_position.bottom,
        name = "thruster-control-behavior",
      }
    }
    footer.style.width = 448
    footer.style.horizontal_align = "right"
    footer.style.padding = 4

    local piston = footer.add{
      type = "flow",
    }
    piston.style.horizontally_stretchable = true

    local button = footer.add{
      type = "sprite-button",
      name = "thruster-control-behavior-confirm",
      sprite = "utility/confirm_slot",
      style = "item_and_count_select_confirm",
    }
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "thruster-control-behavior-confirm" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.opened = nil
  end
end)

script.on_event("thruster-control-behavior-open-gui", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local selected = player.selected
  if selected and is_thruster[get_entity_name(selected)] then
    local power_switch = get_power_switch_from_thruster(selected)
    player.opened = power_switch
  end
end)

-- debug only "heavy mode"
-- script.on_event(defines.events.on_tick, function(event)
-- -- script.on_nth_tick(600, function(event)
--   for struct_id, struct in pairs(storage.structs) do
--     assert(struct.thruster.valid)
--     assert(struct.power_switch.valid)
--   end
-- end)
