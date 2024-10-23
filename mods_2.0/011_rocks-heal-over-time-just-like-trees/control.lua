local function get_unique_index(entity)
  return entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.name
end

local function maybe_add_to_damaged_rocks(entity)
  if storage.whitelisted_names[entity.name] and 1 > entity.get_health_ratio() then
    local unique_index = get_unique_index(entity)
    if not storage.damaged_rocks[unique_index] then
      storage.damaged_rocks[unique_index] = entity
    end
  end
end

script.on_event(defines.events.on_entity_damaged, function(event)
  maybe_add_to_damaged_rocks(event.entity)
end, {{filter = "type", type = "simple-entity"}})

local function should_whitelist(simple_entity)
  if string.find(simple_entity.name, "rock") then
    return true
  end

  if simple_entity.localised_name and simple_entity.localised_name[1] and simple_entity.localised_name[1] == "entity-name.meteorite" then
    return true
  end

  return false
end

local function on_init(event)
  storage = {}
  storage.damaged_rocks = {}
  storage.whitelisted_names = {}

  for _, simple_entity in pairs(prototypes.get_entity_filtered({{filter = "type", type = "simple-entity"}})) do
    if should_whitelist(simple_entity) then
      storage.whitelisted_names[simple_entity.name] = true
    end
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "simple-entity"}) do
      maybe_add_to_damaged_rocks(entity)
    end
  end
end

script.on_init(on_init)
script.on_configuration_changed(on_init)

script.on_nth_tick(60 * 10, function(event) -- heal by 1 health every 10 seconds, this is on-par with trees.
  for _, damaged_rock in pairs(storage.damaged_rocks) do

    if damaged_rock.valid and 1 > damaged_rock.get_health_ratio() then
      damaged_rock.health = damaged_rock.health + 1
    else
      storage.damaged_rocks[_] = nil
    end

  end
end)
