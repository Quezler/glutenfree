function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    storage_chests = {}, -- entities keyed by unit number
    car_for = {},
    sunroof_for = {},
    storage_chest_for = {},

    -- storage_chest_by_unit_number = {}
  }
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

--

function Handler.create_storage_chest_index(surfacedata, struct)
  surfacedata.storage_chests[struct.entity.unit_number] = struct

  surfacedata.car_for[struct.entity.unit_number] = struct.car
  surfacedata.storage_chest_for[struct.car.unit_number] = struct.entity
  surfacedata.sunroof_for[struct.entity.unit_number] = struct.sunroof_id
end

function Handler.delete_storage_chest_index(surfacedata, struct)
  surfacedata.car_for[struct.entity.unit_number] = nil
  surfacedata.storage_chest_for[struct.car.unit_number] = nil
  surfacedata.sunroof_for[struct.entity.unit_number] = nil

  surfacedata.storage_chests[struct.entity.unit_number] = nil
end
