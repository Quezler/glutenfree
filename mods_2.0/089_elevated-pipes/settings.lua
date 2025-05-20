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
