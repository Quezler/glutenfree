local flib_position = require("__flib__.position")
local flib_direction = require("__flib__.direction")
local flib_math = require("__flib__.math")

local Handler = {}

script.on_init(function()
  storage.demolishers = {}
  storage.deathrattles = {}
  storage.show_debug_for = {}

  storage.player_needle_pointing_at = {}
  storage.players_holding_compasses = {}
  storage.any_player_holding_compass = false

  if game.surfaces["vulcanus"] then
    local demolishers = game.surfaces["vulcanus"].find_entities_filtered{
      type = "segmented-unit"
    }

    for _, demolisher in ipairs(demolishers) do
      Handler.register_demolisher(demolisher)
    end
  end

  -- game.print(table_size(storage.demolishers))
end)

function Handler.register_demolisher(entity)
  -- game.print(string.format("registered demolisher #%d", entity.unit_number))
  storage.demolishers[entity.unit_number] = {
    entity = entity,
    territory = {},
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = true
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "demolisher-compass-demolisher-created" then return end
  assert(event.target_entity.type == "segmented-unit") -- some mod added this effect_id to random triggers?
  Handler.register_demolisher(event.target_entity)
end)

local function position_key(position)
  assert(position.x)
  assert(position.y)
  return string.format("[%g, %g]", position.x, position.y)
end

-- demolishers move slow, so every 10 seconds we check which chunk every demolisher is in,
-- instead of flagging we're counting since demolishers can arc outside their territory for a bit,
-- so the higher the number is the more likely it is that the demolisher is wandering its own territory.
script.on_nth_tick(600, function(event)
  for _, demolisher in pairs(storage.demolishers) do
    local chunk_position = flib_position.to_chunk(demolisher.entity.position)
    local chunk_key = position_key(chunk_position)

    local chunk = demolisher.territory[chunk_key]
    if chunk == nil then
      local left_top = flib_position.from_chunk(chunk_position)
      local right_bottom = {left_top.x + 32, left_top.y + 32}

      demolisher.territory[chunk_key] = {
        position = chunk_position,

        center = {left_top.x + 16, left_top.y + 16},
        left_top = flib_position.from_chunk(chunk_position),
        right_bottom = {left_top.x + 32, left_top.y + 32},

        visits = 1,
      }
    else
      chunk.visits = chunk.visits + 1
    end
  end

  Handler.visualize()
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local demolisher = storage.demolishers[event.useful_id]
    if demolisher then storage.demolishers[event.useful_id] = nil
      -- kill any render objects
    end
  end
end)

function Handler.visualize(player_identification)
  local surface = game.surfaces["vulcanus"]
  if surface == nil then return end

  for player_index, player in pairs(storage.show_debug_for) do
    if player.connected == false then
      storage.show_debug_for = nil
    end
  end

  -- avoid creating the debug objects if there are no (online) players to see it.
  if next(storage.show_debug_for) == nil then return end

  for _, demolisher in pairs(storage.demolishers) do
    for _, chunk in pairs(demolisher.territory) do

      rendering.draw_rectangle{
        surface = surface,

        left_top = chunk.left_top,
        right_bottom = chunk.right_bottom,

        color = {0.25, 0, 0, 0.1},
        filled = true,
        players = storage.show_debug_for,
        time_to_live = 600,
      }

      rendering.draw_text{
        surface = surface,
        target = chunk.center,

        text = chunk.visits,
        color = {1, 1, 1},

        scale = 5,
        alignment = "center",
        vertical_alignment = "middle",

        players = storage.show_debug_for,
        time_to_live = 600,
      }

    end
  end
end

commands.add_command("demolisher-compass", "Toggle rendering debug objects.", function(command)
  local player = game.get_player(command.player_index)
  assert(player)

  if storage.show_debug_for[command.player_index] then
    storage.show_debug_for[command.player_index] = nil
    player.print("[demolisher-compass] debug visuals disabled.")
  else
    storage.show_debug_for[command.player_index] = player
    player.print("[demolisher-compass] debug visuals enabled.")
  end
end)

function flib_direction.from_positions(source, target, round)
  local deg = math.deg(math.atan2(target.y - source.y, target.x - source.x))
  local direction = (deg + 90) / 22.5
  if direction < 0 then
    direction = direction + 16
  end
  if round then
    direction = flib_math.round(direction)
  end
  return direction --[[@as defines.direction]]
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

  -- -- if math.random(1, 2) > 1 then
  --   if new_direction > old_direction then
  --     next_direction = next_direction + 1
  --   end
  --   if new_direction < old_direction then
  --     next_direction = next_direction - 1
  --   end
  -- -- end

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

    -- local zero_to_16 = flib_direction.from_positions(player.position, {x = 0, y = 0}, false)
    -- local zero_to_27 = zero_to_16 / 16 * 27
    -- local sprite_nr = flib_math.round(zero_to_27)
    -- sprite_nr = (sprite_nr + 14) % 28

    local sprite_nr = (storage.player_needle_pointing_at[player.index] or 16) + math.random(0, 16) - 8
    -- local sprite_nr = math.random(0, 27)
    -- local sprite_nr = (storage.player_needle_pointing_at[player.index] or 16) + 6

    request_needle_direction(player, sprite_nr)

    ::continue::
  end

  if table_size(storage.players_holding_compasses) == 0 then
    game.print("any player holding a compass = false")
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
      game.print("any player holding a compass = true")
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
