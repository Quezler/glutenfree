local mod_prefix = "upgrade-planner-toggle-entity-with-pipette--"

data:extend({
  {
      type = "bool-setting",
      name = mod_prefix .. "bring-your-own-keybind",
      setting_type = "startup",
      default_value = false,
  },
})
