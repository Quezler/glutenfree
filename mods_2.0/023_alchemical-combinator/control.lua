-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

-- /c game.player.teleport({0, 0}, "alchemical-combinator")

local arithmetic_combinator_parameters = require("scripts.arithmetic_combinator_parameters")
local decider_combinator_parameters = require("scripts.decider_combinator_parameters")

local ModSurface = require("scripts.mod-surface")
local mod_surface_name = ModSurface.name

local Handler = {}

script.on_init(function()
  storage.index = 0
  storage.structs = {}

  storage.deathrattles = {}

  storage.alchemical_combinator_to_struct_id = {}
  storage.alchemical_combinator_active_to_struct_id = {}

  storage.active_struct_ids = {}

  local mod_surface = game.surfaces[mod_surface_name]
  if mod_surface then
    for _, entity in ipairs(mod_surface.find_entities_filtered{}) do
      entity.destroy() -- unlike surface.clear() this is instant
    end
  end
  if mod_surface == nil then
    mod_surface = game.create_surface(mod_surface_name)
    mod_surface.generate_with_lab_tiles = true
  end

  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  storage.index = storage.index + 1
  local struct_id = storage.index

  local struct = {
    -- index = storage.index,
    alchemical_combinator = entity,
    alchemical_combinator_active = nil,

    sprite_render_object = nil,

    arithmetic = nil,
    constant = nil,
    decider = nil,

    conditions = {},
    deciders = {},
  }

  storage.structs[struct_id] = struct
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct_id, alchemical_combinator_to_struct_id = entity.unit_number}

  storage.alchemical_combinator_to_struct_id[entity.unit_number] = struct_id

  local mod_surface = game.surfaces[mod_surface_name]
  local arithmetic = mod_surface.create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {struct_id - 1, -1.0},
  }
  assert(arithmetic)
  struct.arithmetic = arithmetic
  arithmetic.get_control_behavior().parameters = arithmetic_combinator_parameters

  -- outside to inside
  local green_in_a =     entity.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  local green_in_b = arithmetic.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  assert(green_in_a.connect_to(green_in_b, false, defines.wire_origin.script))
  local red_in_a =     entity.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  local red_in_b = arithmetic.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(red_in_a.connect_to(red_in_b, false, defines.wire_origin.script))

  local constant = mod_surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {struct_id - 1, -2.5},
    direction = defines.direction.south,
  }
  assert(constant)
  struct.constant = constant

  local decider = mod_surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {struct_id - 1, -4.0},
  }
  assert(decider)
  struct.decider = decider
  decider.get_control_behavior().parameters = decider_combinator_parameters

  local blacklist_green_in =    decider.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  local blacklist_red_in   =    decider.get_wire_connector(defines.wire_connector_id.combinator_input_red  , false)
  local constant_green_out =   constant.get_wire_connector(defines.wire_connector_id.circuit_green         , false)
  local arithmetic_red_out = arithmetic.get_wire_connector(defines.wire_connector_id.combinator_output_red , false)
  assert(arithmetic_red_out.connect_to(blacklist_red_in  , false))
  assert(constant_green_out.connect_to(blacklist_green_in, false))

  -- inside to outside
  local green_out_a =  entity.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  local green_out_b = decider.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  assert(green_out_a.connect_to(green_out_b, false, defines.wire_origin.script))
  local red_out_a =  entity.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)
  local red_out_b = decider.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)
  assert(red_out_a.connect_to(red_out_b, false, defines.wire_origin.script))
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
    {filter = "name", name = "alchemical-combinator"},
  })
end

local direction_to_sprite = {
  [defines.direction.north] = "alchemical-combinator-active-north",
  [defines.direction.east ] = "alchemical-combinator-active-east" ,
  [defines.direction.south] = "alchemical-combinator-active-south",
  [defines.direction.west ] = "alchemical-combinator-active-west" ,
}

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)
  local selected = player.selected

  if selected and selected.name == "alchemical-combinator" and player.is_cursor_empty() then -- todo: re-select when cursor gets cleared?
    local struct_id = storage.alchemical_combinator_to_struct_id[selected.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    local active = selected.surface.create_entity{
      name = "alchemical-combinator-active",
      force = selected.force,
      position = selected.position,
      direction = selected.direction,
      create_build_effect_smoke = false,
    }
    assert(active)
    active.last_user = selected.last_user

    local green_in_a = selected.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
    local green_in_b =   active.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
    assert(green_in_a.connect_to(green_in_b, false, defines.wire_origin.script))
    local red_in_a = selected.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
    local red_in_b =   active.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
    assert(red_in_a.connect_to(red_in_b, false, defines.wire_origin.script))

    struct.sprite_render_object = rendering.draw_sprite{
      sprite = direction_to_sprite[selected.direction],
      surface = selected.surface,
      target = active,
      -- time_to_live = 60,
      render_layer = "higher-object-under",
    }

    struct.alchemical_combinator_active = active
    storage.alchemical_combinator_active_to_struct_id[active.unit_number] = struct_id
    storage.deathrattles[script.register_on_object_destroyed(active)] = {alchemical_combinator_active_to_struct_id = active.unit_number}

    storage.active_struct_ids[struct_id] = true
    selected.surface.play_sound{
      path = "alchemical-combinator-charge",
      position = selected.position,
    }
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity

  if entity and entity.name == "alchemical-combinator-active" then
    local struct_id = storage.alchemical_combinator_active_to_struct_id[entity.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    assert(struct.alchemical_combinator)
    assert(struct.alchemical_combinator.valid)
    player.opened = struct.alchemical_combinator
  end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  local struct_id = storage.alchemical_combinator_active_to_struct_id[event.entity.unit_number]
  local struct = storage.structs[struct_id]

  local player = game.get_player(event.player_index)
  assert(player)
  player.mine_entity(struct.alchemical_combinator)
end, {
  {filter = "name", name = "alchemical-combinator-active"},
})

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle.struct_id then
      local struct = storage.structs[deathrattle.struct_id]
      assert(struct)
      storage.structs[deathrattle.struct_id] = nil
      struct.arithmetic.destroy()
      struct.constant.destroy()
      struct.decider.destroy()
      for _, decider in ipairs(struct.deciders) do
        decider.destroy()
      end
    end

    if deathrattle.alchemical_combinator_to_struct_id then
      storage.alchemical_combinator_to_struct_id[deathrattle.alchemical_combinator_to_struct_id] = nil
    end

    if deathrattle.alchemical_combinator_active_to_struct_id then
      storage.alchemical_combinator_active_to_struct_id[deathrattle.alchemical_combinator_active_to_struct_id] = nil
    end

  end
end)

local function selected_by_any_player(entity)
  for _, player in ipairs(game.connected_players) do
    if player.connected and player.selected then
      -- game.print(player.selected.name)
      if player.selected == entity then
        return true
      end
    end
  end

  return false
end

function Handler.on_tick(event)
  for struct_id, _ in pairs(storage.active_struct_ids) do
    local struct = storage.structs[struct_id]
    assert(struct)

    -- during the first tick(s?) the player is still selecting the normal combinator
    if (not selected_by_any_player(struct.alchemical_combinator_active)) and (not selected_by_any_player(struct.alchemical_combinator)) then
      storage.active_struct_ids[struct_id] = nil

      struct.alchemical_combinator.surface.play_sound{
        path = "alchemical-combinator-uncharge",
        position = struct.alchemical_combinator.position,
      }

      struct.alchemical_combinator_active.destroy()
      struct.alchemical_combinator_active = nil
    end
  end
end

script.on_event(defines.events.on_tick, Handler.on_tick)

script.on_event(defines.events.on_gui_closed, ModSurface.on_gui_closed)

require("scripts.trivial-event-handlers")
