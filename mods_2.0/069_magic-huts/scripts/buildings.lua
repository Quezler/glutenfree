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

  if entity.tags and entity.tags[mod_prefix .. "factory-index"] then
    return entity.tags[mod_prefix .. "factory-index"]
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
  end

  -- if not factory_index then return end
  -- local factory = storage.factories[factory_index]
  -- if not factory then return end

  local building = new_struct(storage.buildings, {
    index = entity.unit_number,
    entity = entity,
    is_ghost = entity.type == "entity-ghost",

    line_1 = nil,
    line_2 = nil,
    line_3 = nil,
    line_4 = nil,
  })

  local factory_config = config.factories[mod.container_name_to_tier[get_entity_name(entity)]]

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

  Buildings.set_status_not_configured(building)

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "building", building_index = building.index}

  if factory_index then
    local factory = storage.factories[factory_index]
    if factory then
      Buildings.set_factory(building, factory)
      Factories.refresh_list()
    end
  end
end

Buildings.set_status_not_configured = function(building)
  building.line_1.text = ""
  building.line_2.text = ""
  building.line_3.text = "[img=utility/status_inactive] not configured"
  building.line_4.text = "head into factory planner and export a factory"
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

  factory.count = factory.count + 1
  building.factory_index = factory.index
end

Buildings.on_object_destroyed = function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "building" then
      local building = storage.buildings[event.useful_id]
      if building then storage.buildings[event.useful_id] = nil
        if building.factory_index then
          local factory = storage.factories[building.factory_index]
          if factory then
            factory.count = factory.count - 1
            Factories.refresh_list()
          end
        end
      end
    end
  end
end

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local blueprint = event.stack
  if blueprint == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}
  for i, blueprint_entity in ipairs(blueprint_entities) do
    if mod.container_names_map[blueprint_entity.name] then
      local entity = event.mapping.get()[i]
      local factory_index = storage.buildings[entity.unit_number].factory_index
      if factory_index then
        blueprint.set_blueprint_entity_tag(i, mod_prefix .. "factory-index", factory_index)
      end
    end
  end
end)

-- script.on_event(defines.events.on_player_pipette, function(event)
--   local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
--   local selected = player.selected
--   if not selected then return end

--   local entity_name = selected.type == "entity-ghost" and selected.ghost_name or selected.name
--   if not mod.container_names_map[entity_name] then return end

--   local factory_index = storage.buildings[selected.unit_number].factory_index
--   if factory_index then
--     storage.playerdata[player.index].held_factory_index = factory_index
--   end
-- end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if mod.container_names_map[get_entity_name(event.source)] and mod.container_names_map[get_entity_name(event.destination)] then
    local building_a = storage.buildings[event.source.unit_number]
    local building_b = storage.buildings[event.destination.unit_number]

    if building_a.factory_index == building_b.factory_index then return end -- early bail to avoid unnecessary work

    local factory_a = storage.factories[building_a.factory_index]
    local factory_b = storage.factories[building_b.factory_index]

    if factory_b then
      factory_b.count = factory_b.count - 1
    end

    if factory_a then
      Buildings.set_factory(building_b, factory_a)
    else
      Buildings.set_status_not_configured(building_b)
      building_b.factory_index = nil
    end
    Factories.refresh_list()
  end
end)

return Buildings
