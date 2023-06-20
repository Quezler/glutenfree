function Handler.create_storage_chest_index(surfacedata, struct)
  surfacedata.storage_chests[struct.entity.unit_number] = struct

  surfacedata.car_for[struct.entity.unit_number] = struct.car
  surfacedata.storage_chest_for[struct.car.unit_number] = struct.entity
  surfacedata.sunroof_for[struct.entity.unit_number] = struct.sunroof_id
end

function Handler.delete_storage_chest_index(surfacedata, struct)
  rendering.destroy(struct.sunroof_id)

  surfacedata.car_for[struct.entity.unit_number] = nil
  surfacedata.storage_chest_for[struct.car.unit_number] = nil
  surfacedata.sunroof_for[struct.entity.unit_number] = nil

  surfacedata.storage_chests[struct.entity.unit_number] = nil
end
