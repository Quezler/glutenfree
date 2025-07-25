for i = 0, 27 do
  local delay = (i == 7 or i == 21) and "15" or "05"
  local icon = string.format("__demolisher-compass__/graphics/icons/compass/frame_%02d_delay-0.%ss.png", i, delay)
  -- log(icon)

  data:extend{{
    type = "item",
    -- name = "demolisher-compass-" .. i,
    name = string.format("demolisher-compass-%02d", i),
    localised_name = {"item-name.demolisher-compass"},

    icon = icon,
    icon_size = 160,

    stack_size = 1,
    flags = {"not-stackable", "only-in-cursor", "spawnable"},

    hidden = true,
    hidden_in_factoriopedia = true,
  }}
end

data:extend{{
  type = "shortcut",
  name = "demolisher-compass",

  icon      = data.raw["item"]["demolisher-compass-16"].icon,
  icon_size = data.raw["item"]["demolisher-compass-16"].icon_size,

  small_icon      = data.raw["item"]["demolisher-compass-16"].icon,
  small_icon_size = data.raw["item"]["demolisher-compass-16"].icon_size,

  action = "spawn-item",
  item_to_spawn = "demolisher-compass-16",
}}
