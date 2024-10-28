local flib_position = require("__flib__.position")
local flib_bounding_box = require("__flib__.bounding-box")

local debug_mode = false

local Handler = {}

local is_mining_drill_entity = {}
for _, entity in pairs(prototypes.entity) do
  is_mining_drill_entity[entity.name] = entity.type == "mining-drill"
end

local is_mining_drill_item = {}
for _, item in pairs(prototypes.item) do
  local place_result = item.place_result
  if place_result and is_mining_drill_entity[place_result.name] then
    is_mining_drill_item[item.name] = true
  else
    is_mining_drill_item[item.name] = false
  end
end

local mining_drill_radius = {}
for entity_name, bool in pairs(is_mining_drill_entity) do
  if bool then mining_drill_radius[entity_name] = prototypes.entity[entity_name].mining_drill_radius end
end

-- true, false, nil
local function is_player_holding_drill(player)
  if player.cursor_ghost then
    return is_mining_drill_item[player.cursor_ghost.name.name]
  end

  if player.cursor_stack.valid_for_read then
    return is_mining_drill_item[player.cursor_stack.prototype.name]
  end
end

script.on_init(function()
  storage.playerdata = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  storage.playerdata = {}
  storage.deathrattles = {}

  rendering.clear("notice-me-senpai")
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  local playerdata = storage.playerdata[player.index]

  if playerdata == nil then
    if is_player_holding_drill(player) then
      storage.playerdata[player.index] = {
        player_index = player.index,
        surface_index = player.surface.index,

        rectangles = {},
        seen_chunks = {},

        ores = {},
        drills = {},

        green_positions = {}, -- "[x, y]" = true
        yellow_positions = {}, -- "[x, y]" = true

        ore_render_objects = {},
        redraw = false,
      }

      Handler.tick_player(event)
    end
  else
    if is_player_holding_drill(player) ~= true then
      for _, rectangle in pairs(playerdata.rectangles) do
        rectangle.destroy()
      end
      for _, ore_render_object in pairs(playerdata.ore_render_objects) do
        ore_render_object.destroy()
      end
      storage.playerdata[player.index] = nil
    end
  end

end)

local function get_chunks_in_viewport(chunk_position)
  local chunk_positions = {}

  local x = chunk_position.x
  local y = chunk_position.y

  -- this gets all the chunks on my 1920 x 1080 screen when i fully zoom out
  local vertical = 2
  local horizontal = 4

  for i = y - vertical, y + vertical do
      for j = x - horizontal, x + horizontal do
          table.insert(chunk_positions, {x = j, y = i})
      end
  end

  return chunk_positions
end

local function get_positions_from_area(area)
  local positions = {}

  local left_top = area.left_top
  local right_bottom = area.right_bottom

  for y = left_top.y, right_bottom.y-1 do
      for x = left_top.x, right_bottom.x-1 do
          table.insert(positions, {x = x, y = y})
      end
  end

  return positions
end

local function position_key(position)
  assert(position.x)
  assert(position.y)
  return string.format("[%g, %g]", position.x, position.y)
end

local function get_color_for_tile_key(playerdata, tile_key)
  if playerdata.green_positions[tile_key] then
    return {0, 0.9, 0, 1} -- green
  elseif playerdata.yellow_positions[tile_key] then
    return {0.9, 0.9, 0, 1} -- yellow
  else
    return {0.9, 0, 0, 1} -- red
  end
end

function Handler.add_ore_to_playerdata(ore, playerdata)
  local tile_left_top = flib_position.to_tile(ore.position)
  local tile_right_bottom = {tile_left_top.x + 1, tile_left_top.y + 1}
  local tile_key = position_key(tile_left_top)

  playerdata.ores[tile_key] = ore

  playerdata.ore_render_objects[tile_key] = rendering.draw_rectangle{
    surface = playerdata.surface_index,

    target = ore,

    left_top = {tile_left_top.x + 0.35, tile_left_top.y + 0.35},
    right_bottom = {tile_right_bottom[1] - 0.35, tile_right_bottom[2] - 0.35},

    color = get_color_for_tile_key(playerdata, tile_key),
    filled = true,

    players = {playerdata.player_index},
    only_in_alt_mode = true,
  }
end

function Handler.add_drill_color_positions(playerdata, drill_struct)
  if drill_struct.entity.valid == false then return end

  for _, tile_position in ipairs(drill_struct.green_positions) do
    playerdata.green_positions[position_key(tile_position)] = true
  end

  for _, tile_position in ipairs(drill_struct.yellow_positions) do
    playerdata.yellow_positions[position_key(tile_position)] = true
  end
end

function Handler.add_drill_to_playerdata(drill, playerdata)
  if playerdata.drills[drill.unit_number] then return end -- either on a chunk border or my mod is bugged

  local drill_name = drill.name == "entity-ghost" and drill.ghost_name or drill.name
  local mining_drill_radius = mining_drill_radius[drill_name]
  assert(mining_drill_radius)

  local bounding_box = flib_bounding_box.ceil(drill.bounding_box)
  local mining_box = flib_bounding_box.ceil(flib_bounding_box.from_dimensions(drill.position, mining_drill_radius * 2, mining_drill_radius * 2))

  local drill_struct = {
    entity = drill,

    green_positions = get_positions_from_area(bounding_box), -- {x = #, y = #}
    yellow_positions = get_positions_from_area(mining_box), -- {x = #, y = #}
  }

  playerdata.drills[drill.unit_number] = drill_struct
  Handler.add_drill_color_positions(playerdata, drill_struct)

  storage.deathrattles[script.register_on_object_destroyed(drill)] = true
end

function Handler.reindex_color_positions(playerdata)
  playerdata.green_positions = {}
  playerdata.yellow_positions = {}

  for _, drill_struct in pairs(playerdata.drills) do
    Handler.add_drill_color_positions(playerdata, drill_struct)
  end
end

function Handler.redraw(playerdata)
  playerdata.redraw = false

  -- we are redrawing because there might be new drills within render distance
  -- log(string.format("recoloring %d ores.", table_size(playerdata.ore_render_objects)))
  for tile_key, ore_render_object in pairs(playerdata.ore_render_objects) do
    if ore_render_object.valid then -- if the ore gets mined this kills itself
      ore_render_object.color = get_color_for_tile_key(playerdata, tile_key)
    end
  end
end

function Handler.tick_player(event)
  local playerdata = storage.playerdata[event.player_index]
  if playerdata == nil then return end

  local player = assert(game.get_player(event.player_index))
  local surface = player.surface

  local chunk_position_with_player = flib_position.to_chunk(player.position)

  for _, chunk_position in ipairs(get_chunks_in_viewport(chunk_position_with_player)) do
    local chunk_key = position_key(chunk_position)
    if playerdata.seen_chunks[chunk_key] then goto continue end
    playerdata.seen_chunks[chunk_key] = true
    playerdata.redraw = true -- stricly speaking only required if there were new ores or drills found in this new chunk

    local left_top = flib_position.from_chunk(chunk_position)
    local right_bottom = {left_top.x + 32, left_top.y + 32}

    if debug_mode then
      local rectangle = rendering.draw_rectangle{
        surface = surface,

        left_top = left_top,
        right_bottom = right_bottom,

        color = {0.25, 0.25, 0.25, 0.1},
        filled = true,
        only_in_alt_mode = true,
        players = {player},
      }

      playerdata.rectangles[rectangle.id] = rectangle
    end

    local ghost_drills = surface.find_entities_filtered{
      area = {left_top, right_bottom},
      ghost_type = "mining-drill",
      force = player.force,
    }
    for _, drill in ipairs(ghost_drills) do
      Handler.add_drill_to_playerdata(drill, playerdata)
    end

    local drills = surface.find_entities_filtered{
      area = {left_top, right_bottom},
      type = "mining-drill",
      force = player.force,
    }
    for _, drill in ipairs(drills) do
      Handler.add_drill_to_playerdata(drill, playerdata)
    end

    local ores = surface.find_entities_filtered{
      area = {left_top, right_bottom},
      type = "resource",
    }
    for _, ore in ipairs(ores) do
      Handler.add_ore_to_playerdata(ore, playerdata)
    end

    ::continue::
  end

  if playerdata.redraw then Handler.redraw(playerdata) end
end

script.on_event(defines.events.on_player_changed_position, Handler.tick_player)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  for _, playerdata in pairs(storage.playerdata) do
    Handler.add_drill_to_playerdata(entity, playerdata)
    Handler.redraw(playerdata)
  end
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
    {filter =       "type", type = "mining-drill"},
    {filter = "ghost_type", type = "mining-drill"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    for _, playerdata in pairs(storage.playerdata) do
      Handler.reindex_color_positions(playerdata)
      Handler.redraw(playerdata)
    end
  end
end)
