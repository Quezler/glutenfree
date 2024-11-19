local mod_prefix = "keep-off-the-grass-and-off-my-planet-silly-goose-"
local mod_directory = "__keep-off-the-grass-and-off-my-planet-silly-goose__"

data:extend{{
  type = "sprite",
  name = mod_prefix .. "no-goose-sign",

  filename = mod_directory .. "/graphics/icons/no-goose-sign.png",
  height = 180,
  width = 180,

  flags = {"icon"},
}}

data:extend{{
  type = "shortcut",
  name = mod_prefix .. "shortcut",

  icon = mod_directory .. "/graphics/icons/no-goose-sign.png",
  icon_size = 180,
  small_icon = mod_directory .. "/graphics/icons/no-goose-sign.png",
  small_icon_size = 180,

  action = "lua",
}}
