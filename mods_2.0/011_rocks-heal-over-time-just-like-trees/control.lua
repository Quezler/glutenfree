local function should_whitelist(prototype)
  -- nauvis
  if string.find(prototype.name, "rock") then
    return true
  end

  -- vulcanus
  if string.find(prototype.name, "chimney") then
    return true
  end

  -- gleba
  if string.find(prototype.name, "stromatolite") then
    return true
  end

  -- space exploration
  if prototype.localised_name and prototype.localised_name[1] and prototype.localised_name[1] == "entity-name.meteorite" then
    return true
  end

  return false
end

local entity_name_whitelisted = {}
for _, prototype in pairs(prototypes.entity) do
  if prototype.type == "simple-entity" then
    entity_name_whitelisted[prototype.name] = should_whitelist(prototype)
  end
end
log(serpent.block(entity_name_whitelisted))

local function get_index(entity)
  return entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.name
end

local function maybe_add_to_damaged_rocks(entity)
  if entity_name_whitelisted[entity.name] and 1 > entity.get_health_ratio() then
    local index = get_index(entity)
    if not storage.damaged_rocks[index] then
      storage.damaged_rocks[index] = entity
    end
  end
end

script.on_event(defines.events.on_entity_damaged, function(event)
  maybe_add_to_damaged_rocks(event.entity)
end, {{filter = "type", type = "simple-entity"}})

local function on_configuration_changed(event)
  storage = {}
  storage.damaged_rocks = {}
  storage.whitelisted_names = nil

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "simple-entity"}) do
      maybe_add_to_damaged_rocks(entity)
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

script.on_nth_tick(60 * 10, function(event) -- heal by 1 health every 10 seconds, this is on-par with trees.
  for _, damaged_rock in pairs(storage.damaged_rocks) do

    if damaged_rock.valid and 1 > damaged_rock.get_health_ratio() then
      damaged_rock.health = damaged_rock.health + 1
    else
      storage.damaged_rocks[_] = nil
    end

  end
end)
