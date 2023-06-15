local Car = {}

-- function Car.create(surface, position, force)
function Car.create_for(storage_chest)
  local car = storage_chest.surface.create_entity{
    name = "logistic-chest-deconstruction-car",
    force = storage_chest.force,
    position = storage_chest.position,
  }

  car.grid.put{name = "logistic-chest-deconstruction-equipment"}

  return car
end

return Car
