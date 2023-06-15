local car = table.deepcopy(data.raw['car']['car'])

car.name = "logistic-chest-deconstruction-car"
car.allow_passengers = false

car.collision_mask = {}
-- car.collision_box = {{0, 0}, {0, 0}}
car.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}

car.turret_animation = nil
car.light_animation = nil
car.animation = {
  layers = {
    {
      animation_speed = 1,
      direction_count = 1,
      filename = "__core__/graphics/empty.png",
      frame_count = 1,
      height = 1,
      width = 1
    },
  }
}

car.guns = nil
car.energy_source = {type = "void"}

data:extend({car})
