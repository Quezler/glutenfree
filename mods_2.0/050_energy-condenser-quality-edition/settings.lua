require("shared")

data:extend({
  {
    type = "string-setting",
    name = mod_prefix .. "skin",
    setting_type = "startup", order = "a",
    default_value = "Disruptor",
    allowed_values = {"Disruptor", "Research center"},
  },
  {
    type = "double-setting",
    name = mod_prefix .. "base-quality",
    setting_type = "startup", order = "b",
    default_value = 0,
    minimum_value = 0,
    maximum_value = 100,
  },
  {
    type = "int-setting",
    name = mod_prefix .. "module-slots",
    setting_type = "startup", order = "c",
    default_value = 3,
    allowed_values = {0, 1, 2, 3, 4, 5, 6},
  },
})
