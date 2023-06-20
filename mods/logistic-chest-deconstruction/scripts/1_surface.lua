function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    storage_chests = {}, -- structs keyed by storage chest's unit_number

    car_for = {},
    storage_chest_for = {},
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
end

function Handler.delete_storage_chest_index(surfacedata, struct)
  surfacedata.car_for[struct.entity_unit_number] = nil
  surfacedata.storage_chest_for[struct.car_unit_number] = nil

  surfacedata.storage_chests[struct.entity_unit_number] = nil
end
