local flib_position = require("__flib__.position")

local Handler = {}

script.on_init(function()
  storage.demolishers = {}
  storage.deathrattles = {}
  storage.show_debug_for = {}

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
    player.print("Demolisher compass debug visuals disabled.")
  else
    storage.show_debug_for[command.player_index] = player
    player.print("Demolisher compass debug visuals enabled.")
  end
end)
