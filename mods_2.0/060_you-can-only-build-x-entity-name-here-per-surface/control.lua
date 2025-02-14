mod = {}

local function refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if surfacedata.surface.valid == false then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      surface = surface,
      entities = {}, -- entity_name -> array[entity]
    }
  end
end

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

script.on_init(function()
  storage.limits = {}

  storage.surfacedata = {}
  refresh_surfacedata()

  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "wooden-chest", {count = 0})
  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "iron-chest", {count = 1})
  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "steel-chest", {count = 2})
end)

script.on_configuration_changed(function()
  storage.limits = {}

  refresh_surfacedata()
end)

function mod.sum_entities(entities, force)
  local sum = 0
  for unit_number, entity in pairs(entities) do
    if entity.valid and entity.force == force then
      sum = sum + 1
    end
  end
  return sum
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  local entity_name = entity.type == "entity-ghost" and entity.ghost_name or entity.name
  local limit = assert(storage.limits[entity_name])

  local surfacedata = storage.surfacedata[entity.surface.index]

  -- we're not gonna seperate them by force, there are lots of events that can shuffle forces around,
  -- and considering in 9 out of 10 cases they're all owned by the same force it is not that important,
  -- also since the nature of this mod is to keep count low i doubt we get lots to go through constantly.
  surfacedata.entities[entity_name] = surfacedata.entities[entity_name] or {}
  local entity_count = mod.sum_entities(surfacedata.entities[entity_name], entity.force)

  if entity_count >= limit.count then
    entity.destroy()
    return
  end

  surfacedata.entities[entity.name][assert(entity.unit_number)] = entity

  -- game.print(string.format("%s (%d)", entity.name, storage.limits[entity.name].limit))
end

function mod.refresh_on_created_entity()
  local filters = {}

  for entity_name, limit in pairs(storage.limits) do
    table.insert(filters, {filter =       "name", name = entity_name})
    table.insert(filters, {filter = "ghost_name", name = entity_name})
  end

  for _, event in ipairs({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.on_space_platform_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    defines.events.on_entity_cloned,
  }) do
    script.on_event(event, mod.on_created_entity, filters)
  end
end

script.on_load(function()
  mod.refresh_on_created_entity()
end)

remote.add_interface("you-can-only-build-x-entity-name-here-per-surface", {
  -- get_limits = function()
  --   return storage.limits
  -- end,
  -- set_limits = function(limits)
  --   storage.limits = limits
  -- end,
  add_limit = function(entity, config)
    assert(type(entity) == "string")
    assert(storage.limits[entity] == nil)
    storage.limits[entity] = {
      count = assert(config.count),
    }
    -- if config == nil or table_size(config) == 0 then
    --   storage.limits[entity] = nil
    -- end

    -- if config.limit then
    --   assert(type(config.limit) == "number")
    --   assert(config.limit >= 0)
    --   storage.limits[entity].limit = config.limit
    -- end

    -- assert(prototypes.entity[data.entity])
    -- storage.limits[data.entity_name]

    mod.refresh_on_created_entity()
  end,
})

