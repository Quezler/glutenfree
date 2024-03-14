local function already_in_damaged_rocks(entity)
  for _, e in pairs(global.damaged_rocks) do
    if e.valid and entity.surface.index == e.surface.index and entity.position.x == e.position.x and entity.position.y == e.position.y then
      return true
    end
  end

  return false
end

local function maybe_add_to_damaged_rocks(entity)
  if string.find(entity.name, "rock") and 1 > entity.get_health_ratio() then
    if global.skip_duplicate_check or not already_in_damaged_rocks(entity) then
      table.insert(global.damaged_rocks, entity)
    end
  end
end

script.on_event(defines.events.on_entity_damaged, function(event)
  maybe_add_to_damaged_rocks(event.entity)
end, {{filter = 'type', type = 'simple-entity'}})

local function on_init(event)
  global.damaged_rocks = {}
  global.skip_duplicate_check = true

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'simple-entity'}) do
      maybe_add_to_damaged_rocks(entity)
    end
  end

  global.skip_duplicate_check = false
  log('#global.damaged_rocks = ' .. #global.damaged_rocks)
end

script.on_init(on_init)
-- script.on_configuration_changed(on_configuration_changed)

script.on_nth_tick(60 * 10, function(event) -- heal by 1 health every 10 seconds, this is on-par with trees.
  for i = #global.damaged_rocks, 1, -1 do
    local damaged_rock = global.damaged_rocks[i]

    if damaged_rock.valid and 1 > damaged_rock.get_health_ratio() then
      damaged_rock.health = damaged_rock.health + 1
    else
      table.remove(global.damaged_rocks, i)
    end
  end
end)
