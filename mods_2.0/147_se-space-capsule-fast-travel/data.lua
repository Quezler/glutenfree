data:extend({
  {
    type = "selection-tool",
    name = "se-space-capsule-fast-travel-targeter",
    icon = data.raw["item"]["se-space-capsule"].icon,
    icon_mipmaps = 4,
    icon_size = 64,
    subgroup = "tool",
    stack_size = 1,

    select = {
      border_color = {r = 0, g = 0, b = 0, a = 0},
      mode = "nothing",
      cursor_box_type = "entity"
    },

    alt_select = {
      border_color = {r = 0, g = 0, b = 0, a = 0},
      mode = "nothing",
      cursor_box_type = "entity"
    },

    hidden = true,
    flags = {"only-in-cursor", "spawnable", "not-stackable"}
  },
  {
      type = "shortcut",
      name = "se-space-capsule-fast-travel",

      action = "spawn-item",
      item_to_spawn = "se-space-capsule-fast-travel-targeter",

      style = "default",
      icon = data.raw["item"]["se-space-capsule"].icon,
      small_icon = data.raw["item"]["se-space-capsule"].icon,
      small_icon_size = 64,
  },
})
