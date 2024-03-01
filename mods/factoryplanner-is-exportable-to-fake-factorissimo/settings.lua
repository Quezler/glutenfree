local mod_prefix = 'fietff-'

data:extend({
  {
    type = "string-setting",
    name = mod_prefix .. 'tier-1-research',
    setting_type = "startup",
    default_value = "production-science-pack",
  },
  {
    type = "string-setting",
    name = mod_prefix .. 'tier-2-research',
    setting_type = "startup",
    default_value = "production-science-pack",
  },
  {
    type = "string-setting",
    name = mod_prefix .. 'tier-3-research',
    setting_type = "startup",
    default_value = "production-science-pack",
  },
})
