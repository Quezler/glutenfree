local mod_prefix = "k11-advanced-centrifuge-"

data:extend({
  {
      type = "bool-setting",
      name = mod_prefix .. "base-productivity",
      setting_type = "startup",
      default_value = false,
  },
})
