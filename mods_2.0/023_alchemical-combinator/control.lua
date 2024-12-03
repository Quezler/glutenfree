-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

-- /c game.player.teleport({0, 0}, "alchemical-combinator")

local arithmetic_combinator_parameters = require("scripts.arithmetic_combinator_parameters")
local decider_combinator_parameters = require("scripts.decider_combinator_parameters")

local AlchemicalCombinator = require("scripts.alchemical-combinator")
local mod_surface_name = "alchemical-combinator"

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

  for _, force in pairs(game.forces) do
    force.set_surface_hidden(mod_surface_name, true)
  end
end)

script.on_configuration_changed(function(event)
  for _, force in pairs(game.forces) do
    force.set_surface_hidden(mod_surface_name, true)
  end
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  storage.index = storage.index + 1
  local struct_id = storage.index

  local struct = {
    id = struct_id,
    alchemical_combinator = entity,
    alchemical_combinator_active = nil,

    sprite_render_object = nil,

    arithmetic = nil,
    constant = nil,
    decider = nil,

    conditions = {},
    arithmetics = {},
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

  AlchemicalCombinator.reread(struct)
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

    active.get_control_behavior().parameters = selected.get_control_behavior().parameters

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
    script.on_event(defines.events.on_tick, Handler.on_tick)
    Handler.tick_active_struct(struct)
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
      for _, arithmetic in ipairs(struct.arithmetics) do
        arithmetic.destroy()
      end
      storage.active_struct_ids[deathrattle.struct_id] = nil -- technically a 1 tick desync gap?
    end

    if deathrattle.alchemical_combinator_to_struct_id then
      storage.alchemical_combinator_to_struct_id[deathrattle.alchemical_combinator_to_struct_id] = nil
    end

    if deathrattle.alchemical_combinator_active_to_struct_id then
      storage.alchemical_combinator_active_to_struct_id[deathrattle.alchemical_combinator_active_to_struct_id] = nil
    end

  end
end)

local function is_copy_source(entity)
  for _, player in ipairs(game.connected_players) do
    if player.connected then
      if player.entity_copy_source and player.entity_copy_source == entity then
        return true
      end
    end
  end

  return false
end

local function selected_by_any_player(entity)
  for _, player in ipairs(game.connected_players) do
    if player.connected then
      if player.selected then
        -- game.print(player.selected.name)
        if player.selected == entity then
          return true
        end
      end
    end

  end

  return false
end

function Handler.tick_active_struct(struct)
  assert(struct)

  if is_copy_source(struct.alchemical_combinator_active) then return end

  -- during the first tick(s?) the player is still selecting the normal combinator
  if (not selected_by_any_player(struct.alchemical_combinator_active)) and (not selected_by_any_player(struct.alchemical_combinator)) then
    storage.active_struct_ids[struct.id] = nil

    struct.alchemical_combinator_active.destroy()
    struct.alchemical_combinator_active = nil
  elseif struct.alchemical_combinator.valid then
    local signals = struct.alchemical_combinator.get_signals(defines.wire_connector_id.combinator_output_red, defines.wire_connector_id.combinator_output_green)
    local parameters = struct.alchemical_combinator.get_control_behavior().parameters
    parameters.conditions = parameters.conditions or {}

    -- trick the -active combinator into enabeling its outside side
    table.insert(parameters.conditions, {
      comparator = "≠",
      compare_type = "or",
      constant = 0,
      first_signal = {
        name = "signal-everything",
        type = "virtual"
      },
      first_signal_networks = {
        green = true,
        red = true
      },
      second_signal_networks = {
        green = true,
        red = true
      }
    })

    -- reset and fill the output side with signals artificially
    local alchemical_combinator_active_cb = struct.alchemical_combinator_active.get_control_behavior()
    alchemical_combinator_active_cb.parameters = parameters
    for _, signal_and_count in ipairs(signals or {}) do
      alchemical_combinator_active_cb.add_output({
        signal = {
          type = signal_and_count.signal.type or "item",
          name = signal_and_count.signal.name,
          quality = signal_and_count.signal.quality,
        },
        constant = signal_and_count.count / 2,
        copy_count_from_input = false,
      })
    end
  end
end

function Handler.on_tick(event)
  for struct_id, _ in pairs(storage.active_struct_ids) do
    local struct = storage.structs[struct_id]
    Handler.tick_active_struct(struct)
  end

  if next(storage.active_struct_ids) == nil then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function()
  if next(storage.active_struct_ids) ~= nil then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.entity and event.entity.name == "alchemical-combinator" then
    local struct_id = storage.alchemical_combinator_to_struct_id[event.entity.unit_number]
    local struct = storage.structs[struct_id]
    AlchemicalCombinator.reread(struct)
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.name == "alchemical-combinator-active" then
    local struct_id = storage.alchemical_combinator_active_to_struct_id[event.destination.unit_number]
    local struct = storage.structs[struct_id]

    struct.alchemical_combinator.get_control_behavior().parameters = struct.alchemical_combinator_active.get_control_behavior().parameters
    AlchemicalCombinator.reread(struct)
  elseif event.destination.name == "alchemical-combinator" then
    local struct_id = storage.alchemical_combinator_to_struct_id[event.destination.unit_number]
    local struct = storage.structs[struct_id]

    AlchemicalCombinator.reread(struct)
  end
end)

require("scripts.trivial-event-handlers")
