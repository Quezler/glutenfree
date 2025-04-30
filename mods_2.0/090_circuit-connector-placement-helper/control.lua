require("util")

require("shared")

local mod = {}

local is_circuit_connector = {}
local next_variation = {}
local previous_variation = {}

mod.on_created_entity_filters = {
  {filter = "name",       name = mod_prefix .. "container"},
  {filter = "ghost_name", name = mod_prefix .. "container"},
}

for i = 0, 39 do
  local this_name = mod_prefix .. "furnace-" .. string.format("%02d", i)
  local next_name = mod_prefix .. "furnace-" .. string.format("%02d", (i + 1) % 40)
  local previous_name = mod_prefix .. "furnace-" .. string.format("%02d", (i - 1) % 40)

  is_circuit_connector[this_name] = true
  next_variation[this_name] = next_name
  previous_variation[this_name] = previous_name

  table.insert(mod.on_created_entity_filters, {filter = "name",       name = this_name})
  table.insert(mod.on_created_entity_filters, {filter = "ghost_name", name = this_name})
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

local function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  local entity_name = get_entity_name(entity)

  if entity_name == mod_prefix .. "container" then
    return entity.destroy()
  end

  if entity.type == "entity-ghost" then
    return entity.revive({raise_revive = true})
  end

  local container = entity.surface.create_entity{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false
  }
  container.destructible = false

  local red_from = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local red_to = container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  red_from.connect_to(red_to, false, defines.wire_origin.player)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

commands.add_command(mod_name, nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]

  if player.clear_cursor() == false then return end
  local cursor_stack = player.cursor_stack

  cursor_stack.set_stack({name = mod_prefix .. "connector-book", count = 1})
  player.cursor_stack_temporary = true
  local pages = cursor_stack.get_inventory(defines.inventory.item_main)

  for i = 0, 39 do
    local furnace_name = mod_prefix .. "furnace-" .. string.format("%02d", i)
    pages.insert({name = "blueprint", count = 1})
    local blueprint = pages[i+1]
    blueprint.label = string.format("%02d", i)
    blueprint.set_blueprint_entities({
      {
        entity_number = 1,
        name = furnace_name,
        position = {0, 0},
        wires = {{1, 1, 2, 1}},
      },
      {
        entity_number = 2,
        name = mod_prefix .. "container",
        position = {0, 0},
      },
    })
    blueprint.preview_icons = {
      {index = 1, signal = {type = "entity", name = furnace_name}},
    }
  end
end)
