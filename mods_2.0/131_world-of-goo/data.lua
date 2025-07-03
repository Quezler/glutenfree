require("namespace")

data:extend{{
  type = "sprite",
  name = "goo-ball",
  filename = mod_directory .. "/graphics/goo-ball-3.png",
  width = 171,
  height = 171,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "common-body",
  filename = mod_directory .. "/graphics/balls/common/body.png",
  width = 64,
  height = 64,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-1",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_1.png",
  width = 32,
  height = 32,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-2",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_2.png",
  width = 23,
  height = 23,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-3",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_3.png",
  width = 16,
  height = 16,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-pupil",
  filename = mod_directory .. "/graphics/balls/_generic/pupil1.png",
  width = 8,
  height = 8,
  scale = 0.25,
}}

data.raw["tile"]["water"].variants.main[1].picture = mod_directory .. "/graphics/terrain/water/crude-oil1.png"
data.raw["tile"]["water"].variants.main[2].picture = mod_directory .. "/graphics/terrain/water/crude-oil2.png"
data.raw["tile"]["water"].variants.main[3].picture = mod_directory .. "/graphics/terrain/water/crude-oil4.png"
data.raw["tile"]["water"].effect_color = {0.2, 0.2, 0.2, 1}
data.raw["tile"]["water"].effect_color_secondary = {0.2, 0.2, 0.2, 1}
data.raw["tile"]["water"].map_color = {0.2, 0.2, 0.2, 1}

data.raw["tile"]["deepwater"].variants.main[1].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil1.png"
data.raw["tile"]["deepwater"].variants.main[2].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil2.png"
data.raw["tile"]["deepwater"].variants.main[3].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil4.png"
data.raw["tile"]["deepwater"].effect_color = {0.1, 0.1, 0.1, 1}
data.raw["tile"]["deepwater"].effect_color_secondary = {0.1, 0.1, 0.1, 1}
data.raw["tile"]["deepwater"].map_color = {0.1, 0.1, 0.1, 1}
