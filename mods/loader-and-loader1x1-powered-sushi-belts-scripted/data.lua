data:extend({
  {
    type = "shortcut",
    name = "sushi-loader-marker",

    action = "spawn-item",
    item_to_spawn = "sushi-loader-marker",

    style = "default",
    icon = {
      layers = {
        {filename = "__base__/graphics/icons/fish.png", size = 64, mipmap_count = 4},
        {filename = "__base__/graphics/icons/steel-axe.png", size = 64, mipmap_count = 4},
      },
    },
  },
  {
    type = "selection-tool",
    name = "sushi-loader-marker",
    -- icon = "__base__/graphics/icons/fish.png",
    -- icon_mipmaps = 4,
    -- icon_size = 64,
    icons = {
      {icon = "__base__/graphics/icons/fish.png", icon_size = 64, icon_mipmaps = 4},
      {icon = "__base__/graphics/icons/steel-axe.png", icon_size = 64, icon_mipmaps = 4},
    },
    subgroup = "tool",
    stack_size = 1,
    selection_color = {r = 0.9, g = 0.9, b = 0.9},
    alt_selection_color = {r = 0.9, g = 0.9, b = 0.9},
    hidden = true,
    flags = {"hidden", "only-in-cursor", "spawnable", "not-stackable"},

    selection_mode = {"same-force", "deconstruct"},
    alt_selection_mode = {"same-force", "deconstruct"},
    reverse_selection_mode = {"same-force", "deconstruct"},
    alt_reverse_selection_mode = {"same-force", "deconstruct"},

    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    reverse_selection_cursor_box_type = "entity",
    alt_reverse_selection_cursor_box_type = "entity",

    entity_type_filters = {'loader', 'loader-1x1'},
    alt_entity_type_filters = {'loader', 'loader-1x1'},
    reverse_entity_type_filters = {'loader', 'loader-1x1'},
    alt_reverse_entity_type_filters = {'loader', 'loader-1x1'},

    entity_filter_mode = "whitelist",
    alt_entity_filter_mode = "whitelist",
    reverse_entity_filter_mode = "whitelist",
    alt_reverse_entity_filter_mode = "whitelist",
  }
})
