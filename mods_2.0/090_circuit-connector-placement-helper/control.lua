require("util")

require("shared")

local is_circuit_connector = {}
local next_variation = {}
local previous_variation = {}

for i = 0, 39 do
  local this_name = mod_prefix .. "furnace-" .. string.format("%02d", i)
  local next_name = mod_prefix .. "furnace-" .. string.format("%02d", (i + 1) % 40)
  local previous_name = mod_prefix .. "furnace-" .. string.format("%02d", (i - 1) % 40)

  is_circuit_connector[this_name] = true
  next_variation[this_name] = next_name
  previous_variation[this_name] = previous_name
end

local function copy_wires(from, to)
  for wire_connector_id, from_wire_connector in pairs(from.get_wire_connectors()) do
    to_wire_connector = to.get_wire_connector(wire_connector_id, true)
    for _, from_connection in ipairs(from_wire_connector.connections) do
      to_wire_connector.connect_to(from_connection.target, false, from_connection.origin)
    end
  end
end

local function rotated_clockwise(event)
  local entity_direction = event.entity.direction
  return false
  or (event.previous_direction == defines.direction.north and entity_direction == defines.direction.east)
  or (event.previous_direction == defines.direction.east and entity_direction == defines.direction.south)
  or (event.previous_direction == defines.direction.south and entity_direction == defines.direction.west)
  or (event.previous_direction == defines.direction.west and entity_direction == defines.direction.north)
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
  local entity = event.entity

  if is_circuit_connector[entity.name] then
    local new_entity = entity.surface.create_entity{
      name = rotated_clockwise(event) and next_variation[entity.name] or previous_variation[entity.name],
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
    }
    copy_wires(entity, new_entity)
    entity.destroy()
  end
end)

local input_name_to_nudge = {
  ["circuit-connector-placement-helper--right"] = util.by_pixel( 0.5,  0.0),
  ["circuit-connector-placement-helper--left" ] = util.by_pixel(-0.5,  0.0),
  ["circuit-connector-placement-helper--down" ] = util.by_pixel( 0.0,  0.5),
  ["circuit-connector-placement-helper--up"   ] = util.by_pixel( 0.0, -0.5),
  ["circuit-connector-placement-helper--shift-right"] = util.by_pixel( 2.0,  0.0),
  ["circuit-connector-placement-helper--shift-left" ] = util.by_pixel(-2.0,  0.0),
  ["circuit-connector-placement-helper--shift-down" ] = util.by_pixel( 0.0,  2.0),
  ["circuit-connector-placement-helper--shift-up"   ] = util.by_pixel( 0.0, -2.0),
}

script.on_event({
  "circuit-connector-placement-helper--right",
  "circuit-connector-placement-helper--left",
  "circuit-connector-placement-helper--down",
  "circuit-connector-placement-helper--up",
  "circuit-connector-placement-helper--shift-right",
  "circuit-connector-placement-helper--shift-left",
  "circuit-connector-placement-helper--shift-down",
  "circuit-connector-placement-helper--shift-up",
}, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local selected = player.selected

  if selected and is_circuit_connector[selected.name] then
    local nudge = input_name_to_nudge[event.input_name]
    selected.teleport(nudge[1], nudge[2])
  end
end)
