data:extend{{
  type = "planet",
  name = "world-of-goo",
  icon = mod_directory .. "/graphics/balls/common/body.png",

  distance = 15,
  orientation = 0.32,

  starmap_icon = "blep",
  starmap_icons = {
    {icon = mod_directory .. "/graphics/balls/common/body.png", size = 64, scale = 1},

    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_2.png", icon_size = 23, shift = {-0.50 * 32, -0.10 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = {-0.45 * 32, -0.15 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_1.png", icon_size = 32, shift = { 0.30 * 32, -0.30 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = { 0.35 * 32, -0.35 * 32}, scale = 1, floating = true},

    {icon = mod_directory .. "/graphics/telescope-19x19.png", icon_size = 19, shift = { 0.7 * 32, -1.2 * 32}, scale = 1.5, floating = true},
  }
}}
