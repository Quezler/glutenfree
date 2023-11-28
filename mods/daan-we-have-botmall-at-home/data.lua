data:extend({
  {
    type = "shortcut",
    name = "daan-we-have-botmall-at-home",

    action = "spawn-item",
    item_to_spawn = "daan-we-have-botmall-at-home",

    style = "default",
    icon = {filename = "__base__/graphics/icons/coin.png", size = 64, mipmap_count = 4},
  },
  {
    type = "selection-tool",
    name = "daan-we-have-botmall-at-home",
    icon = "__base__/graphics/icons/coin.png",
    icon_mipmaps = 4,
    icon_size = 64,
    subgroup = "tool",
    stack_size = 1,
    selection_color = {r = 0.9, g = 0.9, b = 0.9},
    alt_selection_color = {r = 0.9, g = 0.9, b = 0.9},
    selection_mode = {"nothing"},
    alt_selection_mode = {"nothing"},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    hidden = true,
    flags = {"hidden", "only-in-cursor", "spawnable", "not-stackable"}
  }
})
