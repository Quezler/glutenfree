local mod_surface_name = "inactivity-combinator"

local input_side = defines.circuit_connector_id.combinator_input
local output_side = defines.circuit_connector_id.combinator_output

script.on_init(function ()
  global.deathrattles = {}
  global.x_offset = 0

  local surface = game.surfaces[mod_surface_name]
  assert(surface == nil)

  surface = game.create_surface(mod_surface_name)
  surface.generate_with_lab_tiles = true

  surface.create_entity{
    name = 'electric-energy-interface',
    force = 'neutral',
    position = {-1, -1},
  }
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
  if event.last_entity == nil then return end
  if event.last_entity.name ~= "inactivity-combinator" then return end

  -- disconnect any green input wires that do not come from our surface.
  for _, connection in ipairs(event.last_entity.circuit_connection_definitions) do
    if connection.wire == defines.wire_type.green and connection.source_circuit_id == defines.circuit_connector_id.combinator_input then
      if connection.target_entity.surface.name ~= mod_surface_name then
        event.last_entity.disconnect_neighbour(connection)
      end
    end
  end

  local player = game.get_player(event.player_index)
  assert(player)

  -- unclip the held wire when you're trying to drag it somewhere,
  -- you could still clip it to its own output, but the above check will take care of that.
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "green-wire" then
    if player.drag_target and player.drag_target.target_circuit_id == defines.circuit_connector_id.combinator_input then
      player.clear_cursor() -- apparently this just cancels the wire, i do not need to re-add it to the player's hand :)
    end
  end
end)

local function connect_wire(from_entity, to_entity, color, from_connector, to_connector)
  local success = from_entity.connect_neighbour({
    wire = assert(defines.wire_type[color], color),
    target_entity = to_entity,
    source_circuit_id = from_connector,
    target_circuit_id = to_connector
  })

  assert(success, 'are you building on the inactivity-combinator surface?')
end

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  assert(event.destination == nil, 'for cloning all pre-existing wires need to be cut via code.')

  local surface = game.surfaces[mod_surface_name]

  -- enouch reach for the 4 combinators
  local pole_1 = surface.create_entity{
    name = 'medium-electric-pole',
    force = 'neutral',
    position = {x = 1.5 + global.x_offset, y = -0.5},
  }

  -- each + 0 = each
  local combinator_1 = surface.create_entity{
    name = 'arithmetic-combinator',
    force = 'neutral',
    position = {x = 1 + global.x_offset, y = 0.5},
    direction = defines.direction.east,
  }

  -- everything == t?, everything input count
  local combinator_2 = surface.create_entity{
    name = 'decider-combinator',
    force = 'neutral',
    position = {x = 1 + global.x_offset, y = 1.5},
    direction = defines.direction.east,
  }

  -- t + 2 = t
  local combinator_3 = surface.create_entity{
    name = 'arithmetic-combinator',
    force = 'neutral',
    position = {x = 1 + global.x_offset, y = 2.5},
    direction = defines.direction.west,
  }

  -- t / 60 = s
  local combinator_4 = surface.create_entity{
    name = 'arithmetic-combinator',
    force = 'neutral',
    position = {x = 1 + global.x_offset, y = 3.5},
    direction = defines.direction.east,
  }

  assert(pole_1)
  assert(combinator_1)
  assert(combinator_2)
  assert(combinator_3)
  assert(combinator_4)

  connect_wire(combinator_1, entity, 'red', input_side, input_side) -- in

  connect_wire(combinator_1, combinator_2, 'red', input_side, input_side)
  connect_wire(combinator_1, combinator_2, 'green', output_side, input_side)

  connect_wire(combinator_2, combinator_3, 'green', input_side, output_side)
  connect_wire(combinator_2, combinator_3, 'green', output_side, input_side)

  connect_wire(combinator_3, combinator_4, 'green', output_side, input_side)

  connect_wire(combinator_4, entity, 'green', output_side, input_side) -- out

  -- if the combinator uses the default configuration, override it it with S and Z signals
  if serpent.line(entity.get_control_behavior().parameters) == '{comparator = "<", constant = 0, copy_count_from_input = true, first_signal = {type = "item"}, output_signal = {type = "item"}}' then
    entity.get_control_behavior().parameters = {comparator = ">", constant = 60, copy_count_from_input = false, first_signal = {name = "signal-S", type = "virtual"}, output_signal = {name = "signal-Z", type = "virtual"}}
  end

  -- /c log(serpent.line(game.player.selected.get_control_behavior().parameters))
  combinator_1.get_control_behavior().parameters = {first_signal = {name = "signal-each", type = "virtual"}, operation = "+", output_signal = {name = "signal-each", type = "virtual"}, second_constant = 0}
  combinator_2.get_control_behavior().parameters = {comparator = "=", copy_count_from_input = true, first_signal = {name = "signal-everything", type = "virtual"}, output_signal = {name = "signal-everything", type = "virtual"}, second_signal = {name = "signal-T", type = "virtual"}}
  combinator_3.get_control_behavior().parameters = {first_signal = {name = "signal-T", type = "virtual"}, operation = "+", output_signal = {name = "signal-T", type = "virtual"}, second_constant = 2}
  combinator_4.get_control_behavior().parameters = {first_signal = {name = "signal-T", type = "virtual"}, operation = "/", output_signal = {name = "signal-S", type = "virtual"}, second_constant = 60}

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {combinator_1, combinator_2, combinator_3, combinator_4} -- not the pole!

  global.x_offset = global.x_offset + 2
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'inactivity-combinator'},
  })
end

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, combinator in ipairs(deathrattle) do
      combinator.destroy()
    end
  end
end)
