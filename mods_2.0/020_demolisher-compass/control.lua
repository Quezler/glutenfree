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
