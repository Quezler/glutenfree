local config = require("config")

local Buildings = {}

local function get_factory_index(event)
  local entity = event.entity or event.destination

  if event.player_index and storage.playerdata[event.player_index] then
    local held_factory_index = storage.playerdata[event.player_index].held_factory_index
    if held_factory_index then -- if nil, go for checking the ghost tags
      return held_factory_index
    end
  end

  if event.tags and event.tags[mod_prefix .. "factory-index"] then
    return event.tags[mod_prefix .. "factory-index"]
  end

  if entity.last_user and storage.playerdata[entity.last_user.index] then
    return storage.playerdata[entity.last_user.index].held_factory_index
  end

  return nil
end

Buildings.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local factory_index = get_factory_index(event)

  if entity.type == "entity-ghost" then
    if factory_index then
      local tags = entity.tags or {}
      tags[mod_prefix .. "factory-index"] = factory_index
      entity.tags = tags
    end
    return
  end

  -- if not factory_index then return end
  -- local factory = storage.factories[factory_index]
  -- if not factory then return end

  local building = {
    entity = entity,
    line_1 = nil,
    line_2 = nil,
    line_3 = nil,
    line_4 = nil,
  }
  storage.buildings[entity.unit_number] = building

  local factory_config = config.factories[mod.container_name_to_tier[entity.name]]

  building.line_1 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_name},
    alignment = "center",
    use_rich_text = true,
    scale = 1,
  }

  building.line_2 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_description},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  building.line_3 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_message},
    alignment = "center",
    use_rich_text = true,
    scale = 1,
  }

  building.line_4 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_verbose},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  if factory_index then
    Buildings.set_factory(building, Factories.from_index(factory_index))
  end
end

local function get_description(factory)
  local description = ""

  for _, product in ipairs(factory.export.products) do
    description = description .. string.format("[%s=%s]", product.type, product.name)
  end
  description = description .. " - "

  if #factory.export.byproducts > 0 then
    for _, byproduct in ipairs(factory.export.byproducts) do
      description = description .. string.format("[%s=%s]", byproduct.type, byproduct.name)
    end
    description = description .. " - "
  end

  for _, ingredient in ipairs(factory.export.ingredients) do
    description = description .. string.format("[%s=%s]", ingredient.type, ingredient.name)
  end

  return description
end

Buildings.set_factory = function (building, factory)
  assert(building)
  assert(factory)

  building.line_1.text = factory.export.name
  building.line_2.text = get_description(factory)
  building.line_3.text = "[img=utility/status_not_working] not yet implemented"
  building.line_4.text = "Quezler is still working hard on the rest"
end

return Buildings
