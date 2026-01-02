require("namespace")

data:extend({
  {
    order = "a",
    type = "int-setting",
    name = mod_prefix .. "max-underground-distance",
    setting_type = "startup",
    default_value = 30,
    minimum_value = 2,
  },
})
