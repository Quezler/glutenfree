data:extend({
  {
    type = "selection-tool",
    name = "cliff-reconstruction-selection-tool",
    icon = data.raw["capsule"]["cliff-explosives"].icon,
    subgroup = "tool",
    stack_size = 1,

    select =
    {
      border_color = {r = 47, g = 186, b = 210, a = 255},
      mode = {"nothing"},
      cursor_box_type = "not-allowed",
    },
    alt_select =
    {
      border_color = {0, 0, 0, 0},
      mode = {"nothing"},
      cursor_box_type = "not-allowed",
    },
    reverse_select =
    {
      border_color = data.raw["deconstruction-item"]["deconstruction-planner"].select.border_color,
      mode = {"nothing"},
      cursor_box_type = "not-allowed",
    },
    reverse_alt_select =
    {
      border_color = {0, 0, 0, 0},
      mode = {"nothing"},
      cursor_box_type = "not-allowed",
    },
    super_forced_select =
    {
      border_color = {0, 0, 0, 0},
      mode = {"nothing"},
      cursor_box_type = "not-allowed",
    },

    hidden = true,
    flags = {"only-in-cursor", "spawnable", "not-stackable"}
  },
  {
      type = "shortcut",
      name = "cliff-reconstruction-selection-tool",

      action = "spawn-item",
      item_to_spawn = "cliff-reconstruction-selection-tool",

      style = "default",
      icon = data.raw["capsule"]["cliff-explosives"].icon,
      small_icon = data.raw["capsule"]["cliff-explosives"].icon,
  },
})
