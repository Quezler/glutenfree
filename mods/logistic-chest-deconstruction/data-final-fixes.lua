local empty_animation = {
  animation_speed = 1,
  direction_count = 1,
  filename = "__core__/graphics/empty.png",
  frame_count = 1,
  height = 1,
  width = 1
}

--

local equipment_grid = {
  type = "equipment-grid",
  name = "logistic-chest-deconstruction-equipment_grid",
  equipment_categories = {"logistic-chest-deconstruction-equipment-category"},
  width = 1,
  height = 1,
  locked = true,
}

local car = table.deepcopy(data.raw['car']['car'])

car.name = "logistic-chest-deconstruction-car"
car.allow_passengers = false

car.collision_mask = {}
car.collision_box = {{0, 0}, {0, 0}} -- surface.find_entity
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

car.equipment_grid = equipment_grid.name
car.inventory_size = 0

local equipment = {
  -- roboport equipment
  type = "roboport-equipment",
  name = "logistic-chest-deconstruction-equipment",

  recharging_animation = empty_animation,
  spawn_and_station_height = 0,
  charge_approach_distance = 0,
  construction_radius = 0,
  charging_energy = "1GW",

  charging_station_count = 100,

  -- equipment
  sprite = util.empty_sprite(),
  shape = {width = 1, height = 1, type = "full"},
  categories = {"logistic-chest-deconstruction-equipment-category"},
  energy_source = {
    type = "electric",
    buffer_capacity = "1GJ",
    usage_priority = "primary-input",
  },
  take_result = "raw-fish", -- why bother defining an item for it
}

data:extend({car, equipment_grid, equipment, {type = "equipment-category", name = "logistic-chest-deconstruction-equipment-category"}})
