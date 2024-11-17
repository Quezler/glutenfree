require("scripts.helpers")

local Handler = {}

local function create_struct()
  storage.index = storage.index + 1
  storage.structs[storage.index] = {
    id = storage.index,

    surface = nil,
    position = nil,

    thruster = nil,
    power_switch = nil,
  }
  return storage.structs[storage.index]
end

local function struct_set_thruster(struct, thruster)
  assert(thruster)
  assert(thruster.valid)

  struct.thruster = thruster

  storage.deathrattles[script.register_on_object_destroyed(thruster)] = {type = "thruster", struct_id = struct.id}
  storage.unit_number_to_struct_id[thruster.unit_number] = struct.id
end

local function struct_set_power_switch(struct, power_switch)
  assert(power_switch)
  assert(power_switch.valid)

  struct.power_switch = power_switch

  storage.deathrattles[script.register_on_object_destroyed(power_switch)] = {type = "power-switch", struct_id = struct.id}
  storage.unit_number_to_struct_id[power_switch.unit_number] = struct.id
end

local function get_control_behavior_position(thruster)
  return {thruster.position.x - 1.5, thruster.position.y - 1.0}
end

local function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

function Handler.on_init()
  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}

  storage.unit_number_to_struct_id = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = "thruster"}) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

script.on_init(Handler.on_init)

local function on_created_thruster(entity)
  local power_switch_position = get_control_behavior_position(entity)
  local power_switch = surface_find_entity_or_ghost(entity.surface, power_switch_position, "thruster-control-behavior")
  if power_switch == nil then
    if entity.type == "entity-ghost" then
      power_switch = entity.surface.create_entity{
        name = "entity-ghost",
        ghost_name = "thruster-control-behavior",
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.minable = false
    else
      power_switch = entity.surface.create_entity{
        name = "thruster-control-behavior",
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.destructible = false
    end
    power_switch.power_switch_state = true
  end

  local struct_id = storage.unit_number_to_struct_id[power_switch.unit_number]
  local struct = struct_id and assert(storage.structs[struct_id]) or create_struct()
  -- game.print(game.tick)
  -- local struct = create_struct()
  struct.surface = entity.surface
  struct.position = entity.position
  struct_set_thruster(struct, entity)
  struct_set_power_switch(struct, power_switch)

  Handler.on_power_switch_touched(power_switch)
end

local function on_created_thruster_control_behavior(entity)
  local thruster = surface_find_entity_or_ghost(entity.surface, entity.position, "thruster")
  if thruster == nil then return entity.destroy() end

  local cb_position = get_control_behavior_position(thruster)
  if entity.position.x ~= cb_position[1] or entity.position.y ~= cb_position[2] then return entity.destroy() end

  assert(entity.quality.name == "normal") -- why would you even place a higher quality circuit connector manually?
end


function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  local entity_name = get_entity_name(entity)

  if entity_name == "thruster" then return on_created_thruster(entity) end
  if entity_name == "thruster-control-behavior" then return on_created_thruster_control_behavior(entity) end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name"      , name = "thruster"},
    {filter = "ghost_name", name = "thruster"},
    {filter = "name"      , name = "thruster-control-behavior"},
    {filter = "ghost_name", name = "thruster-control-behavior"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    storage.unit_number_to_struct_id[event.useful_id] = nil

    if deathrattle.type == "thruster" then
      local struct = assert(storage.structs[deathrattle.struct_id])
      local new_thruster = surface_find_entity_or_ghost(struct.surface, struct.position, "thruster")
      if new_thruster then
        struct_set_thruster(struct, new_thruster)

        if new_thruster.type == "entity-ghost" and struct.power_switch.type ~= "entity-ghost" then
          struct.power_switch.destructible = true
          assert(struct.power_switch.die(struct.power_switch.force))
          struct_set_power_switch(struct, surface_find_entity_or_ghost(struct.surface, get_control_behavior_position(new_thruster), "thruster-control-behavior"))
          struct.power_switch.minable = false
        elseif new_thruster.type ~= "entity-ghost" and struct.power_switch.type == "entity-ghost" then
          struct.power_switch.destructible = true
          local _, new_power_switch = struct.power_switch.revive{}
          struct_set_power_switch(struct, new_power_switch)
          struct.power_switch.destructible = false
        end
      else
        struct.power_switch.destroy()
        storage.structs[struct.id] = nil
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

  if entity.power_switch_state == true then
    struct.thruster.active = true
    struct.thruster.custom_status = nil
  else
    struct.thruster.active = false
    struct.thruster.custom_status = {
      diode = defines.entity_status_diode.red,
      label = {"entity-status.disabled-by-control-behavior"},
    }
  end
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected

  if entity and get_entity_name(entity) == "thruster-control-behavior" then
    Handler.on_power_switch_touched(entity)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  if entity and get_entity_name(entity) == "thruster-control-behavior" then
    Handler.on_power_switch_touched(entity)
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local entity = event.destination

  if get_entity_name(entity) == "thruster-control-behavior" then
    Handler.on_power_switch_touched(entity)
  elseif get_entity_name(entity) == "thruster" and get_entity_name(event.source) == "thruster" then
    -- support copying thruster onto truster too, so players are not required to always copy the control behavior
    local old_power_switch = storage.structs[storage.unit_number_to_struct_id[event.source.unit_number]].power_switch
    local new_power_switch = storage.structs[storage.unit_number_to_struct_id[entity.unit_number]].power_switch
    new_power_switch.copy_settings(old_power_switch, event.player_index)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "thruster-control-behavior" then
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
    footer.style.horizontally_stretchable = true
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

-- debug only "heavy mode"
script.on_event(defines.events.on_tick, function(event)
-- script.on_nth_tick(600, function(event)
  for struct_id, struct in pairs(storage.structs) do
    assert(struct.thruster.valid)
    assert(struct.power_switch.valid)
  end
end)
