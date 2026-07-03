local mod_prefix = "newsletter-for-mods-made-by-quezler-"

data:extend{{
  type = "sprite",
  name = mod_prefix .. "crater",

  filename = "__newsletter-for-mods-made-by-quezler__/graphics/crater.png",
  height = 24,
  width = 24,

  flags = {"icon"},
}}

data:extend{{
  type = "shortcut",
  name = mod_prefix .. "shortcut",

  icon = "__newsletter-for-mods-made-by-quezler__/graphics/crater.png",
  icon_size = 24,
  small_icon = "__newsletter-for-mods-made-by-quezler__/graphics/crater.png",
  small_icon_size = 24,

  action = "lua",
}}
