require("shared")

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.spawner({
  name = "pathogen-lab",
  width = 4000, height = 4000,
  total_frames = 60,
  shadow_width = 800, shadow_height = 700,
})

local entity = {
  type = "unit-spawner",
  name = mod_name,
  icon = skin.icon,

  graphics_set = skin.graphics_set,
  max_count_of_owned_units = 2,
  max_friends_around_to_spawn = 4,
  spawning_cooldown = {60 * 1, 60 * 2},
  spawning_radius = 10,
  spawning_spacing = 1,

  -- don't these control like the same thing?
  max_richness_for_spawn_shift = 0,
  max_spawn_shift = 0,

  call_for_help_radius = 0,
  result_units = {
    {
      unit = "small-spitter",
      spawn_points = {
        {
          evolution_factor = 0,
          spawn_weight = 1,
        }
      },
    }
  },
}

data:extend{entity}
