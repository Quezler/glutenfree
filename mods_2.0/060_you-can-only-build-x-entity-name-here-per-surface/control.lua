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

script.on_init(function()
  storage.limits = {}

  storage.surfacedata = {}
  refresh_surfacedata()

  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "wooden-chest", {limit = 0})
  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "iron-chest", {limit = 1})
  remote.call("you-can-only-build-x-entity-name-here-per-surface", "add_limit", "steel-chest", {limit = 2})
end)

script.on_configuration_changed(function()
  storage.limits = {}

  refresh_surfacedata()
end)

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

local function on_created_entity(event)
  local entity = event.entity or event.destination

  game.print(string.format("%s (%d)", entity.name, storage.limits[entity.name].limit))
end

local function refresh_on_created_entity()
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
    script.on_event(event, on_created_entity, filters)
  end
end

script.on_load(function()
  refresh_on_created_entity()
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
      limit = assert(config.limit),
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

    refresh_on_created_entity()
  end,
})

