local roboport = {
  type = "roboport",
  name = "rorfc-roboport",

  base = util.empty_sprite(),
  base_animation = util.empty_sprite(),
  base_patch = util.empty_sprite(),

  charge_approach_distance = data.raw["roboport"]["roboport"].charge_approach_distance,
  charging_energy = data.raw["roboport"]["roboport"].charging_energy,

  door_animation_up = util.empty_sprite(),
  door_animation_down = util.empty_sprite(),

  energy_source = {type = "void"},
  energy_usage = data.raw["roboport"]["roboport"].energy_usage,

  radar_range = 0,
  logistics_radius = 1000000,
  construction_radius = 1000000,
  logistics_connection_distance = 1000000,

  material_slots_count = 0,

  recharge_minimum = data.raw["roboport"]["roboport"].recharge_minimum,
  recharging_animation = util.empty_sprite(),

  request_to_open_door_timeout = 0,
  robot_slots_count = 0,

  spawn_and_station_height = 0,

  collision_mask = {layers = {}},
  flags = {"not-on-map"},

  collision_box = {{-1, -1}, {1, 1}},
  hidden = true,
}

-- debug mode
if false then
  roboport.base = {
    filename = "__core__/graphics/icons/unknown.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    scale = 0.5,
  }
end

data:extend({roboport})

data.raw["utility-sprites"]["default"].construction_radius_visualization = util.empty_sprite()
data.raw["utility-sprites"]["default"].logistic_radius_visualization = util.empty_sprite()
