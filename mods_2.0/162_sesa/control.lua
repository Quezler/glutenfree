local SESA = {}

script.on_init(function()
  storage.new_surfaces = {}

  SESA.try_hide_surfaces()
end)

script.on_configuration_changed(function(event)
  storage.new_surfaces = storage.new_surfaces or {}

  SESA.try_hide_surfaces()

  local function upgrading_from_before(version)
    return event.mod_changes["sesa"] and event.mod_changes["sesa"].old_version and helpers.compare_versions(event.mod_changes["sesa"].old_version, version) == -1
  end

  if upgrading_from_before("1.0.2") then
    for _, surface in pairs(game.surfaces) do
      if surface.planet and surface.name ~= "nauvis" then
        surface.regenerate_entity()
      end
    end
  end

  if upgrading_from_before("1.0.7") then
    for _, surface in pairs(game.surfaces) do
      if surface.planet and surface.name == "fulgora" then
        surface.regenerate_entity("scrap")
      end
    end
  end
end)

script.on_load(function()
  if storage.new_surfaces and table_size(storage.new_surfaces) > 0 then
    script.on_event(defines.events.on_tick, SESA.on_tick)
  end
end)

script.on_event(defines.events.on_surface_created, function(event)
  storage.new_surfaces[event.surface_index] = true
  script.on_event(defines.events.on_tick, SESA.on_tick)
end)

SESA.on_tick = function()
  for surface_index, _ in pairs(storage.new_surfaces) do
    SESA.try_hide_surface(game.get_surface(surface_index))
  end
  storage.new_surfaces = {}
  script.on_event(defines.events.on_tick, nil)
end

SESA.try_hide_surface = function(surface)
  if surface.name == "nauvis" then return end

  if remote.call("space-exploration", "get_surface_type", {surface_index = surface.index}) then
    game.forces.player.set_surface_hidden(surface, true)
  end
end

SESA.try_hide_surfaces = function()
  for _, surface in pairs(game.surfaces) do
    SESA.try_hide_surface(surface)
  end
end
