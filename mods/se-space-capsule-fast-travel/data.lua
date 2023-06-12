
local targeter = table.deepcopy(data.raw["selection-tool"]["se-space-capsule-targeter"])
targeter.name = "se-space-capsule-fast-travel-targeter"
targeter.icon = data.raw["item"]["se-space-capsule"].icon
table.insert(targeter.flags, "spawnable")

data:extend({
  {
      type = "shortcut",
      name = "se-space-capsule-fast-travel",

      action = "spawn-item",
      item_to_spawn = "se-space-capsule-fast-travel-targeter",

      style = "default",
      icon = {filename = data.raw["item"]["se-space-capsule"].icon, size = 64, mipmap_count = 4},
  },
  targeter
})
