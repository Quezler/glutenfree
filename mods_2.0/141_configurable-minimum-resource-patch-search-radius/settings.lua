require("namespace")

data:extend({
  {
    type = "int-setting",
    name = mod_prefix .. "minimum-resource-patch-search-radius",
    setting_type = "startup",
    default_value = 20,
    minimum_value = 0,
  },
})
