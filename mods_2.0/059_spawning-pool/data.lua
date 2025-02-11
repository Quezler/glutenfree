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

function make_optical_fiber_pictures(path, name_prefix, data)
  local all_pictures = {}
  local func = function(t) return t end -- modified
  for key, t in pairs(data) do
    if t.empty then
      all_pictures[key] = { priority = "extra-high", filename = "__core__/graphics/empty.png", width = 1, height = 1 }
    else
      local tile_pictures = {}
      for i = 1, (t.variations or 1) do
        local sprite = func
        {
          priority = "extra-high",
          filename = path .. name_prefix .. "-" .. (t.name or string.gsub(key, "_", "-")) .. ".png", -- modified
          width = (t.width or 128) * 2, -- modified
          height = (t.height or 128) * 2, -- modified
          scale = 0.5,
          shift = t.shift or {1, 1} ,-- modified
          tint = {0.1, 0, 0, 1}, -- custom
        }
        table.insert(tile_pictures, sprite)
      end
      all_pictures[key] = tile_pictures
    end
  end
  return all_pictures
end

local pipe = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
pipe.icon = mod_directory .. "/graphics/icons/optical-fiber.png"
pipe.connection_sprites = make_optical_fiber_pictures(mod_directory .. "/graphics/entity/opticalfiber/", "opticalfiber",
{
  single = { name = "straight-vertical-single", width = 160, height = 160, shift = {1.25, 1.25} },
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
  cross = {},
  ending_up = {},
  ending_down = {},
  ending_right = {},
  ending_left = {},
})
-- error(serpent.block(heat_pipe.connection_sprites))

data:extend{entity, pipe}
