local flib_position = require("__flib__.position")
local flib_direction = require("__flib__.direction")
local flib_math = require("__flib__.math")

local Handler = {}

script.on_init(function()
  storage.player_needle_pointing_at = {}
  storage.players_holding_compasses = {}
  storage.any_player_holding_compass = false
end)

script.on_configuration_changed(function()
  storage.demolishers = nil
  storage.deathrattles = nil
  storage.show_debug_for = nil
  storage.last_chunk_of_player = nil
end)

local function position_key(position)
  assert(position.x)
  assert(position.y)
  return string.format("[%g, %g]", position.x, position.y)
end

local is_demolisher_compass = {}
for i = 0, 27 do
  is_demolisher_compass[string.format("demolisher-compass-%02d", i)] = true
end

local function player_is_holding_compass(player)
  local cursor_stack = player.cursor_stack
  return cursor_stack and cursor_stack.valid_for_read and is_demolisher_compass[cursor_stack.name]
end

local function request_needle_direction(player, new_direction)
  local old_direction = (storage.player_needle_pointing_at[player.index] or 16)
  local next_direction = old_direction

  local diff = (new_direction - old_direction) % 28
  if diff == 0 then return end

  if diff > 14 then
    diff = diff - 28
  end

  local change = math.random(1, math.abs(diff))

  if diff > 0 then
    next_direction = next_direction + change
  elseif diff < 0 then
    next_direction = next_direction - change
  end

  next_direction = next_direction % 28
  storage.player_needle_pointing_at[player.index] = next_direction

  player.cursor_stack.set_stack({name = string.format("demolisher-compass-%02d", next_direction)})
end

function Handler.on_nth_tick_10(event)
  for player_index, player in pairs(storage.players_holding_compasses) do
    if player.connected == false then
      storage.players_holding_compasses[player.index] = nil
      player.clear_cursor()
      goto continue
    end

    if player_is_holding_compass(player) == false then goto continue end

    local chunk_position = flib_position.to_chunk(player.position)
    local territory = player.surface.get_territory_for_chunk(chunk_position)
    local demolisher, sprite_nr

    if territory then
      local segmented_unit = territory.get_segmented_units()[1]
      if segmented_unit then
        local head = segmented_unit.segments[1]
        if head and head.entity then
          demolisher = head.entity
        end
      end
    end

    if demolisher and demolisher.valid then
      local zero_to_16 = flib_direction.from_positions(player.position, demolisher.position, false)
      local zero_to_27 = zero_to_16 / 16 * 27
      sprite_nr = flib_math.round(zero_to_27)
      sprite_nr = (sprite_nr + 14) % 28
    else
      sprite_nr = (storage.player_needle_pointing_at[player.index] or 16) + math.random(0, 16) - 8
    end
    request_needle_direction(player, sprite_nr)

    ::continue::
  end

  if table_size(storage.players_holding_compasses) == 0 then
    -- game.print("any player holding a compass = false")
    storage.any_player_holding_compass = false
    script.on_nth_tick(10, nil)
  end
end

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  if player_is_holding_compass(player) then
    storage.players_holding_compasses[player.index] = player
    if storage.any_player_holding_compass == false then
      -- game.print("any player holding a compass = true")
      storage.any_player_holding_compass = true
      script.on_nth_tick(10, Handler.on_nth_tick_10)
    end
  else
    storage.players_holding_compasses[player.index] = nil
    storage.player_needle_pointing_at[player.index] = nil
  end
end)

script.on_load(function()
  if storage.any_player_holding_compass then
    script.on_nth_tick(10, Handler.on_nth_tick_10)
  end
end)
