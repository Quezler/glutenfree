require("util")

require("shared")

local mod = {}

local is_circuit_connector = {}
local circuit_connector_to_variation = {}
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
  circuit_connector_to_variation[this_name] = i
  next_variation[this_name] = next_name
  previous_variation[this_name] = previous_name

  table.insert(mod.on_created_entity_filters, {filter = "name",       name = this_name})
  table.insert(mod.on_created_entity_filters, {filter = "ghost_name", name = this_name})
end

local colors = { -- copied from data.raw["lamp"]["small-lamp"].signal_to_color_mapping (smuggling via mod-data would be more effort)
  {type = "virtual", name = "signal-red",    color = {1, 0, 0}},
  {type = "virtual", name = "signal-green",  color = {0, 1, 0}},
  {type = "virtual", name = "signal-blue",   color = {0, 0, 1}},
  {type = "virtual", name = "signal-yellow", color = {1, 1, 0}},
  {type = "virtual", name = "signal-pink",   color = {1, 0, 1}},
  {type = "virtual", name = "signal-cyan",   color = {0, 1, 1}},
  {type = "virtual", name = "signal-white",  color = {1, 1, 1}},
  {type = "virtual", name = "signal-grey",   color = {0.5, 0.5, 0.5}},
  {type = "virtual", name = "signal-black",  color = {0, 0, 0}}
}

script.on_init(function()
  storage.deathrattles = {}
end)

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
    assert(new_entity)
    copy_wires(entity, new_entity)
    storage.deathrattles[script.register_on_object_destroyed(new_entity)] = storage.deathrattles[script.register_on_object_destroyed(entity)]
    storage.deathrattles[script.register_on_object_destroyed(entity)] = nil
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
    storage.deathrattles[script.register_on_object_destroyed(selected)].teleport(selected.position)
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

  storage.deathrattles[script.register_on_object_destroyed(entity)] = container
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
  -- player.cursor_stack_temporary = true
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

function mod.hide_from_search(entity)
  return entity.type == "character" or is_circuit_connector[entity.name] or entity.name == mod_prefix .. "container"
end

function bounding_box(position, range)
  local x = position.x
  local y = position.y
  return {
    { x - range, y - range },
    { x + range, y + range },
  }
end

-- find an unique color for each duplicate entity name (last color when overflowing)
function get_next_color(cache, entity_name)
  -- local signal_color_mapping = colors[math.random(1, #colors)]

  cache[entity_name] = cache[entity_name] or 1
  local signal_color_mapping = colors[cache[entity_name]]
  cache[entity_name] = math.min(#colors, cache[entity_name] + 1)

  return string.sub(signal_color_mapping.name, #"signal-" + 1), signal_color_mapping.name
end

function mod.open_gui(player, entity)
  local text_definitions = {}
  local text_names = {}
  local color_cache = {}

  local entities = entity.surface.find_entities_filtered{
    area = bounding_box(entity.position, settings.global[mod_prefix .. "search-radius"].value),
  }

  local variation = circuit_connector_to_variation[entity.name]
  variation = variation > 10 and tostring(variation) or (" " .. variation)

  for _, other_entity in pairs(entities) do
    if not mod.hide_from_search(other_entity) then
      local x_diff = (entity.position.x - other_entity.position.x) * 32
      local y_diff = (entity.position.y - other_entity.position.y) * 32

      local by_pixel = ""
      if x_diff > 0 then by_pixel = by_pixel .. " " end
      by_pixel = by_pixel .. x_diff .. ", "
      if y_diff > 0 then by_pixel = by_pixel .. " " end
      by_pixel = by_pixel .. y_diff

      local color_name, signal_name = get_next_color(color_cache, other_entity.name)

      table.insert(text_definitions, string.format("{ variation = %s, main_offset = util.by_pixel(%s), shadow_offset = util.by_pixel(%s), show_shadow = true },", variation, by_pixel, by_pixel))
      table.insert(text_names, string.format("[virtual-signal=%s] %s", signal_name, other_entity.name))

      player.create_local_flying_text{
        text = string.format("[virtual-signal=%s]", signal_name),
        position = other_entity.position,
        speed = 0,
        time_to_live = 300,
      }
    end
  end

  if #text_definitions == 0 then
    player.opened = nil
    return
  end

  local frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "frame",
    style = "invisible_frame",
    direction = "horizontal",
  }

  local textfield_definitions = frame.add{
    type = "text-box",
  }
  textfield_definitions.style.minimal_width = 800
  textfield_definitions.text = table.concat(text_definitions, "\n")

  local textfield_names = frame.add{
    type = "text-box",
  }
  textfield_names.style.minimal_width = 400
  textfield_names.text = table.concat(text_names, "\n")

  frame.force_auto_center()
  player.opened = frame
end

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if event.entity and is_circuit_connector[event.entity.name] then
    mod.open_gui(player, event.entity)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    event.element.destroy()
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattle.destroy()
  end
end)
