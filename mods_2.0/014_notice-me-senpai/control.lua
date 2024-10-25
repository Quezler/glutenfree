local flib_position = require("__flib__.position")

local is_mining_drill = {}
for _, item in pairs(prototypes.item) do
  local place_result = item.place_result
  if place_result and place_result.type == "mining-drill" then
    is_mining_drill[item.name] = true
  else
    is_mining_drill[item.name] = false -- not strictly needed
  end
end

-- true, false, nil
local function is_player_holding_drill(player)
  if player.cursor_ghost then
    return is_mining_drill[player.cursor_ghost.name.name]
  end

  if player.cursor_stack.valid_for_read then
    return is_mining_drill[player.cursor_stack.prototype.name]
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

script.on_event(defines.events.on_player_changed_position, function(event)
  local playerdata = storage.playerdata[event.player_index]
  if playerdata == nil then return end

  local player = game.get_player(event.player_index)
  assert(player)

  local chunk_position_with_player = flib_position.to_chunk(player.position)

  for _, chunk_position in ipairs(get_chunks_in_viewport(chunk_position_with_player)) do
    local chunk_key = string.format("[%g, %g]", chunk_position.x, chunk_position.y)
    if playerdata.seen_chunks[chunk_key] then goto continue end
    playerdata.seen_chunks[chunk_key] = true

    local left_top = flib_position.from_chunk(chunk_position)
    local right_bottom = {left_top.x + 32, left_top.y + 32}

    local rectangle = rendering.draw_rectangle{
      surface = player.surface,

      left_top = left_top,
      right_bottom = right_bottom,

      color = {0.25, 0.25, 0.25, 0.1},
      filled = true,
      only_in_alt_mode = true,
      players = {player},
    }

    playerdata.rectangles[rectangle.id] = rectangle
    ::continue::
  end
end)
