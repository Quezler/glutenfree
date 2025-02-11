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

local make_optical_fiber_pictures = function (path, name_prefix, data, draw_as_glow)
  for _, t in pairs(data) do
    t.ommit_number = true
    t.width = t.width or 128
    t.height = t.height or 128
    t.shift = t.shift or {1, 1}
  end
  ---@diagnostic disable-next-line: undefined-global
  return make_heat_pipe_pictures(path, name_prefix, data, draw_as_glow)
end

local pipe = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
pipe.icon = mod_directory .. "/graphics/icons/optical-fiber.png"
pipe.connection_sprites = make_optical_fiber_pictures(mod_directory .. "/graphics/entity/opticalfiber/", "opticalfiber",
{
  single = { name = "straight-vertical-single", shift = {0.75, 0.75} },
  straight_vertical = {},
  straight_horizontal = {},
  corner_right_up = { name = "corner-up-right" },
  corner_left_up = { name = "corner-up-left" },
  corner_right_down = { name = "corner-down-right" },
  corner_left_down = { name = "corner-down-left" },
  t_up = {},
  t_down = {},
  t_right = {},
  t_left = {},
  cross = { width = 160, height = 160 },
  ending_up = {},
  ending_down = {},
  ending_right = {},
  ending_left = {},
})
-- error(serpent.block(heat_pipe.connection_sprites))

data:extend{entity, pipe}
