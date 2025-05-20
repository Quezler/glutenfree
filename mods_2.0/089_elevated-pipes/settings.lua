require("shared")

data:extend({
  {
    type = "int-setting",
    name = mod_prefix .. "max-underground-distance",
    setting_type = "startup",
    default_value = 10,
    minimum_value = 2,
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
