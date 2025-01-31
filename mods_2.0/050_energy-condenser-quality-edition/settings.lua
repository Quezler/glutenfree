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
    type = "int-setting",
    name = mod_prefix .. "base-quality",
    setting_type = "startup", order = "b",
    default_value = 10.0 * 10,
    minimum_value = 0,
    maximum_value = 1000,
  },
})
