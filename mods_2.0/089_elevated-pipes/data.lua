require("shared")

require("prototypes.entity")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.technology")
require("prototypes.sprite")

if mods["factorissimo-2-notnotmelon"] then
  data:extend{{
    type = "pipe",
    name = mod_prefix .. "gingarou-hotel-planned-hotspring-site",

    collision_box = {{-0.1, -0.1}, {0.1, 0.1}}, -- non zero seems to be required
    collision_mask = {layers = {}},

    fluid_box = {
      volume = 1,
      pipe_connections = {},
    },

    horizontal_window_bounding_box = {{0, 0}, {0, 0}},
    vertical_window_bounding_box = {{0, 0}, {0, 0}},

    hidden = true,
  }}
end
