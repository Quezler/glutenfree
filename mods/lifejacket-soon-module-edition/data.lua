local filters = {"mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo", "item-request-proxy"}

data:extend({
  {
    type = "selection-tool",
    name = "lifejacket-soon",
    icon = data.raw["item"]["wood"].icon,
    icon_mipmaps = 4,
    icon_size = 64,
    subgroup = "tool",
    stack_size = 1,
    selection_color = data.raw["upgrade-item"]["upgrade-planner"].selection_color,
    alt_selection_color = {r = 0, g = 0, b = 0, a = 0},
    reverse_selection_color = data.raw["deconstruction-item"]["deconstruction-planner"].selection_color,
    reverse_selection_color = {r = 0, g = 0, b = 0, a = 0},
    alt_reverse_selection_color = {r = 0, g = 0, b = 0, a = 0},

    selection_mode = {"same-force", "deconstruct"},
    alt_selection_mode =  {"nothing"},
    reverse_selection_mode = {"same-force", "deconstruct"},
    reverse_selection_mode = {"nothing"},
    alt_reverse_selection_mode = {"nothing"},

    selection_cursor_box_type = "copy",
    reverse_selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "entity",
    alt_reverse_selection_cursor_box_type = "entity",

    entity_type_filters = {"item-request-proxy"},
    reverse_entity_type_filters = filters,

    hidden = true,
    flags = {"hidden", "only-in-cursor", "spawnable", "not-stackable"}
  },
  {
      type = "shortcut",
      name = "lifejacket-soon",

      action = "spawn-item",
      item_to_spawn = "lifejacket-soon",

      style = "default",
      icon = {filename = data.raw["item"]["wood"].icon, size = 64, mipmap_count = 4},
  },
})
