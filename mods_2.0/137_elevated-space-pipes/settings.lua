require("namespace")

data:extend({
  {
    order = "a",
    type = "int-setting",
    name = mod_prefix .. "max-underground-distance",
    setting_type = "startup",
    default_value = 6 + 2,
    minimum_value = 2,
  },
})
