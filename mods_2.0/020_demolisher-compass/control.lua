local flib_position = require("__flib__.position")

local Handler = {}

script.on_init(function()
  storage.demolishers = {}

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
    demolisher.territory[chunk_key] = (demolisher.territory[chunk_key] or 0) + 1
  end
end)
