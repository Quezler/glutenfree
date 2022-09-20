data:extend({
  {
    type = "int-setting",
    name = "lab-resupply-interval",
    setting_type = "startup",
    minimum_value = 1,
    maximum_value = 3600,
    default_value = 3600,
  },
  {
    type = "int-setting",
    name = "lab-resupply-amount",
    setting_type = "startup",
    minimum_value = 1,
    maximum_value = 1000,
    default_value = 200,
  }
})
