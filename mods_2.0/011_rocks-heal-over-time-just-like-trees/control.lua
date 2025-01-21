local whitelist_if_name_matches = {
  -- ?
}

local whitelist_if_name_contains = {
  -- nauvis
  "%-rock",
  -- vulcanus
  "vulcanus%-chimney",
  "%-demolisher%-corpse",
  -- gleba
  "%-stromatolite",
  "%-stomper%-shell",
  -- fulgora
  "fulgoran%-ruin%-",
  "fulgurite",
  -- aquilo
  "lithium%-iceberg%-",
  -- alien biomes
  "rock%-",
}

local function should_whitelist(prototype)
  for _, string in ipairs(whitelist_if_name_matches) do
    if prototype.name == string then
      return true
    end
  end

  for _, substring in ipairs(whitelist_if_name_contains) do
    if string.find(prototype.name, substring) then
      return true
    end
  end

  -- space exploration
  if prototype.localised_name and prototype.localised_name[1] and prototype.localised_name[1] == "entity-name.meteorite" then
    return true
  end

  return false
end

local whitelisted_names = {}
local blacklisted_names = {}
for _, prototype in pairs(prototypes.entity) do
  if prototype.type == "simple-entity" then
    if should_whitelist(prototype) then
      whitelisted_names[prototype.name] = true
    else
      blacklisted_names[prototype.name] = true
    end
  end
end
log("whitelisted_names: " .. serpent.block(whitelisted_names))
log("blacklisted_names: " .. serpent.block(blacklisted_names))

local function get_index(entity)
  return entity.position.x .. "," .. entity.position.y .. "," .. entity.surface.name
end

local function maybe_add_to_damaged_rocks(entity)
  if whitelisted_names[entity.name] and 1 > entity.get_health_ratio() then
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
