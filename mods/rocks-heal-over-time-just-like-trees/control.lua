local function get_unique_index(entity)
  return entity.position.x .. ',' .. entity.position.y .. ',' .. entity.surface.name
end

local function maybe_add_to_damaged_rocks(entity)
  if string.find(entity.name, "rock") and 1 > entity.get_health_ratio() then
    local unique_index = get_unique_index(entity)
    if not global.damaged_rocks[unique_index] then
      global.damaged_rocks[unique_index] = entity
    end
  end
end

script.on_event(defines.events.on_entity_damaged, function(event)
  maybe_add_to_damaged_rocks(event.entity)
end, {{filter = 'type', type = 'simple-entity'}})

local function on_init(event)
  global = {}
  global.damaged_rocks = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'simple-entity'}) do
      maybe_add_to_damaged_rocks(entity)
    end
  end
end

script.on_init(on_init)
script.on_configuration_changed(on_init)

script.on_nth_tick(60 * 10, function(event) -- heal by 1 health every 10 seconds, this is on-par with trees.
  for _, damaged_rock in pairs(global.damaged_rocks) do

    if damaged_rock.valid and 1 > damaged_rock.get_health_ratio() then
      damaged_rock.health = damaged_rock.health + 1
    else
      global.damaged_rocks[_] = nil
    end

  end
end)
