return function(mod)
  function mod.refresh_surfacedata()
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
        structs = {},

        fragment_name = nil,
        zone_radius = 0,

        total_seams = 0,
        total_miners = 0,
      }
    end
  end

  script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
  script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)
end
