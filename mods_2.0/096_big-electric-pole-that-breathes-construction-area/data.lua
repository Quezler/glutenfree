local util = require("util")

local big_electric_pole = data.raw["electric-pole"]["big-electric-pole"]

local roboport = {
  type = "roboport",
  name = "big-electric-pole-roboport",

  base = util.empty_sprite(),
  base_animation = util.empty_sprite(),
  base_patch = util.empty_sprite(),

  charge_approach_distance = data.raw["roboport"]["roboport"].charge_approach_distance,
  charging_energy = data.raw["roboport"]["roboport"].charging_energy,

  construction_radius = big_electric_pole.maximum_wire_distance + 2,

  door_animation_up = util.empty_sprite(),
  door_animation_down = util.empty_sprite(),

  energy_source = {type = "void"},
  energy_usage = data.raw["roboport"]["roboport"].energy_usage,

  logistics_radius = 0,
  logistics_connection_distance = big_electric_pole.maximum_wire_distance + 2,

  material_slots_count = 0,

  recharge_minimum = data.raw["roboport"]["roboport"].recharge_minimum,
  recharging_animation = util.empty_sprite(),

  request_to_open_door_timeout = 0,
  robot_slots_count = 0,

  spawn_and_station_height = 0,

  collision_mask = {layers = {}},
  flags = {"not-on-map", "placeable-off-grid"},

  collision_box = big_electric_pole.collision_box,
  selection_box = big_electric_pole.collision_box,
  selection_priority = (big_electric_pole.selection_priority or 50) - 1,
  selectable_in_game = false,
}

roboport.base_animation = {
  layers = {
    {
      filename = "__base__/graphics/entity/roboport/roboport-base-animation.png",
      priority = "medium",
      width = 83,
      height = 59,
      frame_count = 8,
      animation_speed = 0.5,
      shift = util.add_shift({0, -2.5}, {0.01, -0.75}),
      scale = 0.45,
    },
    {
      filename = "__big-electric-pole-that-breathes-construction-area__/graphics/repair_turret_shadow_animation.png",
      width = 59,
      height = 60,
      animation_speed = 0.5,
      line_length = 1,
      frame_count = 8,
      shift = util.add_shift({3.5, 0.1}, {0.15, -0.15}),
      draw_as_shadow = true,
      scale = 0.45,
    }
  }
}

data:extend({roboport})
