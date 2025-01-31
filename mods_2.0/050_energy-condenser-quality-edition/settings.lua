require("shared")

data:extend({
  {
    type = "string-setting",
    name = mod_prefix .. "skin",
    setting_type = "startup",
    default_value = "Disruptor",
    allowed_values = {"Disruptor", "Research center"}
  },
})
