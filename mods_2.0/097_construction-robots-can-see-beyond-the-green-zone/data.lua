require("shared")

local roboport = {
  type = "roboport",
  name = mod_prefix .. "roboport",
  icon = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-icon.png",

  selection_box = data.raw["roboport"]["roboport"].selection_box,
  collision_box = data.raw["roboport"]["roboport"].collision_box,

  flags = {"placeable-player", "player-creation"},

  base = {
    layers = {
      {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-shadow.png",
        width = 500, height = 350,
        scale = 0.5,
      }
    }
  },
  base_animation = {
    layers = {
      {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-animation-1.png",
        width = 2160 / 8, height = 2480 / 8,
        line_length = 8,
        frame_count = 64,
        scale = 0.5,
      },
        {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-emission-1.png",
        width = 2160 / 8, height = 2480 / 8,
        line_length = 8,
        frame_count = 64,
        scale = 0.5,
        blend_mode = "additive",
        draw_as_glow = true,
      },
    }
  },
  base_patch = util.empty_sprite(),

  charge_approach_distance = data.raw["roboport"]["roboport"].charge_approach_distance,
  charging_energy = data.raw["roboport"]["roboport"].charging_energy,

  door_animation_up = util.empty_sprite(),
  door_animation_down = util.empty_sprite(),

  energy_source = {type = "void"},
  energy_usage = data.raw["roboport"]["roboport"].energy_usage,
  recharge_minimum = data.raw["roboport"]["roboport"].recharge_minimum,

  radar_range = 2,
  logistics_radius = 0,
  construction_radius = 2000000, -- can cover the rest of the map from anywhere

  draw_logistic_radius_visualization = false,
  draw_construction_radius_visualization = false,

  recharging_animation = util.empty_sprite(),
  material_slots_count = 0,
  request_to_open_door_timeout = 0,
  robot_slots_count = 0,
  spawn_and_station_height = 0,
}

data:extend{roboport}
