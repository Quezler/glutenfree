data:extend({
  {
    type = "selection-tool",
    name = "se-space-capsule-fast-travel-targeter",
    icon = data.raw["item"]["se-space-capsule"].icon,
    icon_mipmaps = 4,
    icon_size = 64,
    subgroup = "tool",
    stack_size = 1,
    selection_color = {r = 0, g = 0, b = 0, a = 0},
    alt_selection_color = {r = 0, g = 0, b = 0, a = 0},
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    hidden = true,
    flags = {"hidden", "only-in-cursor", "spawnable", "not-stackable"}
  },
  {
      type = "shortcut",
      name = "se-space-capsule-fast-travel",

      action = "spawn-item",
      item_to_spawn = "se-space-capsule-fast-travel-targeter",

      style = "default",
      icon = {filename = data.raw["item"]["se-space-capsule"].icon, size = 64, mipmap_count = 4},
  },
})
