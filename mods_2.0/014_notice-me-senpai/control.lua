local flib_position = require("__flib__.position")
local flib_bounding_box = require("__flib__.bounding-box")

local debug_mode = false

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
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  -- game.print(event.tick .. ' ' .. serpent.line( is_player_holding_drill(player) ))

  local playerdata = storage.playerdata[player.index]

  if playerdata == nil then
    if is_player_holding_drill(player) then
      storage.playerdata[player.index] = {
        rectangles = {},
        seen_chunks = {},

        -- drills = {},
        green_position = {},
        yellow_position = {},
      }
    end
  else
    if is_player_holding_drill(player) ~= true then
      for _, rectangle in pairs(playerdata.rectangles) do
        rectangle.destroy()
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

  for y = left_top.y, right_bottom.y do
      for x = left_top.x, right_bottom.x do
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

script.on_event(defines.events.on_player_changed_position, function(event)
  local playerdata = storage.playerdata[event.player_index]
  if playerdata == nil then return end

  local player = assert(game.get_player(event.player_index))
  local surface = player.surface

  local chunk_position_with_player = flib_position.to_chunk(player.position)

  for _, chunk_position in ipairs(get_chunks_in_viewport(chunk_position_with_player)) do
    local chunk_key = position_key(chunk_position)
    if playerdata.seen_chunks[chunk_key] then goto continue end
    playerdata.seen_chunks[chunk_key] = true

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

    local drills = surface.find_entities_filtered{
      area = {left_top, right_bottom},
      type = "mining-drill",
      force = player.force,
    }

    for _, drill in ipairs(drills) do
      -- playerdata.drills[drill.unit_number] = drill

      local bounding_box = flib_bounding_box.ceil(drill.bounding_box)
      for _, position in ipairs(get_positions_from_area(bounding_box)) do
        playerdata.green_position[position_key(position)] = true
      end

      local mining_drill_radius = mining_drill_radius[drill.name]
      local mining_box = flib_bounding_box.ceil(flib_bounding_box.from_dimensions(drill.position, mining_drill_radius, mining_drill_radius))
      for _, position in ipairs(get_positions_from_area(mining_box)) do
        playerdata.yellow_position[position_key(position)] = true
      end
    end

    local ores = surface.find_entities_filtered{
      area = {left_top, right_bottom},
      type = "resource",
    }

    for _, ore in ipairs(ores) do
      local tile_left_top = flib_position.to_tile(ore.position)
      local tile_right_bottom = {tile_left_top.x + 1, tile_left_top.y + 1}
      local tile_key = position_key(tile_left_top)

      local color = {0.5, 0, 0, 0.5}
      if playerdata.green_position[tile_key] then
        color = {0, 0.5, 0, 0.5}
      elseif playerdata.yellow_position[tile_key] then
        color = {0.5, 0.5, 0, 0.5}
      end

      local rectangle = rendering.draw_rectangle{
        surface = surface,

        left_top = tile_left_top,
        right_bottom = tile_right_bottom,

        color = color,
        filled = true,
        only_in_alt_mode = true,
        players = {player},
      }

      playerdata.rectangles[rectangle.id] = rectangle
    end

    ::continue::
  end

  -- log(serpent.block(playerdata))
end)