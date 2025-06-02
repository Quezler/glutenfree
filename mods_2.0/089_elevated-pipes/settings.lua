require("shared")

data:extend({
  {
    order = "a",
    type = "int-setting",
    name = mod_prefix .. "max-underground-distance",
    setting_type = "startup",
    default_value = 10,
    minimum_value = 2,
  },
  {
    order = "b",
    type = "bool-setting",
    name = mod_prefix .. "freezes",
    setting_type = "startup",
    default_value = false,
  },
})

data:extend({
  {
    order = "a",
    type = "double-setting",
    name = mod_prefix .. "opacity",
    setting_type = "runtime-per-user",
    minimum_value = 0,
    default_value = 1,
    maximum_value = 1,
  },
})
