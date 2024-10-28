data:extend({
  {
      type = "bool-setting",
      name = "upcycling-no-quality-modules",
      setting_type = "startup",
      default_value = true,
  },
})

data:extend({
  {
      type = "int-setting",
      name = "upcycling-items-per-next-quality",
      setting_type = "runtime-global",
      default_value = 50,
      minimum_value = 1,
  },
})
