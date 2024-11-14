local mod_prefix = "newsletter-for-mods-made-by-quezler-"

data:extend({
  {
      type = "bool-setting",
      name = mod_prefix .. "hijack-goal",
      setting_type = "runtime-per-user",
      default_value = true
  }
})
