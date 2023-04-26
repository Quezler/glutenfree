data.raw["int-setting"]["se-plague-max-runtime-2"] = nil

data:extend({
  {
    type = "double-setting",
    name = "se-plague-max-runtime-2",
    setting_type = "runtime-global",
    default_value = 1 / 60 / 60,
    hidden = true
  }
})
