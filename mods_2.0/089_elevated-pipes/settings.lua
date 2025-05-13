require("shared")

data:extend({
  {
    order = "a",
    type = "int-setting",
    name = mod_prefix .. "max-underground-distance",
    setting_type = "startup",
    minimum_value = 2,
    default_value = 10,
  },
    {
    order = "b",
    type = "double-setting",
    name = mod_prefix .. "opacity",
    setting_type = "startup",
    minimum_value = 0,
    default_value = 1,
    maximum_value = 1,
  },
})
