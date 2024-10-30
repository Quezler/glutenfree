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
    demolisher = entity,
    territory = {},
  }
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "demolisher-compass-demolisher-created" then return end
  assert(event.target_entity.type == "segmented-unit") -- some mod added this effect_id to random triggers?
  Handler.register_demolisher(event.target_entity)
end)
