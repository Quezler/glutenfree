require("shared")

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "pathogen-lab",
  width = 4000, height = 4000,
  total_frames = 60,
  shadow_width = 800, shadow_height = 700,
})

local entity = {
  type = "assembling-machine",
  name = mod_name,
  icon = skin.icon,

  collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
  selection_box = {{-3.5, -3.5}, {3.5, 3.5}},

  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  energy_usage = "1MW",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = -100 }
  },

  crafting_categories = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories),
  icon_draw_specification = {shift = {0.45, -0.375}, scale = 1.5},
}

local heat_pipe = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
error(serpent.block(heat_pipe.connection_sprites))

data:extend{entity}
