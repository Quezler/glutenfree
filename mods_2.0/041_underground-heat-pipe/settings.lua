require("shared")

data:extend({
  {
    type = "string-setting",
    name = mod_prefix .. "heating-radius",
    setting_type = "startup", order = "a",
    default_value = "Directly above",
    allowed_values = {"Directly above", "Around too"},
  },
})
