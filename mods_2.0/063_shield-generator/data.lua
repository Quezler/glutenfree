require("shared")

local cover = {
  type = "simple-entity",
  name = mod_prefix .. "simple-entity",

  icons = {
    {icon = data.raw["item"]["space-platform-foundation"].icon, tint = {0.5, 0.5, 1}},
  },

  selection_box = {{0, 0}, {0, 0}},
  collision_box = {{0, 0}, {0, 0}},

  collision_mask = {layers = {empty_space = true}},
  protected_from_tile_building = false,
  resistances = {
    {
      type = "impact",
        percent = 100
    },
  }
}

data:extend{cover}
