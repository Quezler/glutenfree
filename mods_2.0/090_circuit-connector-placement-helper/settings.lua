require("shared")

data:extend({
  {
    type = "bool-setting",
    name = mod_prefix .. "hide-yellow-base",
    setting_type = "startup",
    default_value = false,
  },
  {
    type = "double-setting",
    name = mod_prefix .. "search-radius",
    setting_type = "runtime-global",
    default_value = 3,
  },
})
