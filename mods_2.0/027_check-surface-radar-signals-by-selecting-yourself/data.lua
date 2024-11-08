local mod_prefix = 'csrsbsy-'

data:extend{{
  type = "spider-vehicle",
  name = mod_prefix .. "spidertron",

  weight = 0,
  braking_force = 1000000,
  friction_force = 0,
  energy_per_hit_point = 0,
  weight = 1,
  friction_force = 1,
  energy_source = {type = "void"},
  inventory_size = 0,
  spider_engine = {legs = {
    {
      leg = mod_prefix .. "spidertron-leg",
      mount_position = {0, 0},
      ground_position = {0, 0},
      walking_group = 1,
    }
  }},
  height = 0,
  chunk_exploration_radius = 0,
  movement_energy_consumption = "1W",
  automatic_weapon_cycling = false,
  chain_shooting_cooldown_modifier = 1,

  selection_box = {{-1, -1}, {1, 1}},
  collision_box = {{-1, -1}, {1, 1}},
}}

data:extend{{
  type = "spider-leg",
  name = mod_prefix .. "spidertron-leg",
  knee_height = 1,
  knee_distance_factor = 1,
  initial_movement_speed = 1000000,
  movement_acceleration = 1000000,
  target_position_randomisation_distance = 0,
  minimal_step_size = 0,
  base_position_selection_distance = 0,
  movement_based_position_selection_distance = 1,
  base_position_selection_distance = 1,
}}

data.raw["item-request-proxy"]["item-request-proxy"].selection_box = {{-1, -1}, {1, 1}}
data.raw["item-request-proxy"]["item-request-proxy"].collision_box = {{-1, -1}, {1, 1}}
data.raw["item-request-proxy"]["item-request-proxy"].selection_priority = 51
