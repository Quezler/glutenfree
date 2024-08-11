data:extend({
  {
    type = "selection-tool",
    name = "cliff-reconstruction-selection-tool",
    icon = data.raw["capsule"]["cliff-explosives"].icon,
    icon_mipmaps = 4,
    icon_size = 64,
    subgroup = "tool",
    stack_size = 1,
    selection_color = {r = 47, g = 186, b = 210, a = 255},
    alt_selection_color = {r = 0, g = 0, b = 0, a = 0},
    reverse_selection_color = data.raw["deconstruction-item"]["deconstruction-planner"].selection_color,
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    hidden = true,
    flags = {"hidden", "only-in-cursor", "spawnable", "not-stackable"}
  },
  {
      type = "shortcut",
      name = "cliff-reconstruction-selection-tool",

      action = "spawn-item",
      item_to_spawn = "cliff-reconstruction-selection-tool",

      style = "default",
      icon = {filename = data.raw["capsule"]["cliff-explosives"].icon, size = 64, mipmap_count = 4},
  },
})
