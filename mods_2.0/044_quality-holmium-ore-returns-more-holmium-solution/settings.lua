local mod_prefix = "quality-holmium-ore-returns-more-holmium-solution--"

data:extend({
  {
      type = "string-setting",
      name = mod_prefix .. "multiplier-math",
      setting_type = "startup",
      default_value = "1 * math.pow(2, quality.level)",
  },
})
