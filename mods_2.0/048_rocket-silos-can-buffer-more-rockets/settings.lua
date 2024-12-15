local mod_prefix = "rocket-silos-can-buffer-more-rockets--"

data:extend({
  {
      type = "int-setting",
      name = mod_prefix .. "rocket-parts-storage-cap-multiplier",
      setting_type = "startup",
      default_value = 1,
      minimum_value = 1,
  },
})
