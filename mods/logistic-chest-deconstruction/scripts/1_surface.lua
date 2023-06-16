function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    storage_chests = {}, -- entities keyed by unit number
    car_for = {},
    sunroof_for = {},
    storage_chest_for = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end
