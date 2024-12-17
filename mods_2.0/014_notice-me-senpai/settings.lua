local mod_prefix = "notice-me-senpai--"

data:extend({
  {
    type = "color-setting",
    name = mod_prefix .. "green",
    setting_type = "runtime-per-user",
    default_value = {0.0, 0.9, 0.0, 1},
  },
  {
    type = "color-setting",
    name = mod_prefix .. "yellow",
    setting_type = "runtime-per-user",
    default_value = {0.9, 0.9, 0.0, 1},
  },
  {
    type = "color-setting",
    name = mod_prefix .. "red",
    setting_type = "runtime-per-user",
    default_value = {0.9, 0.0, 0.0, 1},
  },
})
