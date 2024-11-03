local quality_book = table.deepcopy(data.raw["blueprint-book"]["blueprint-book"])

quality_book.name = "quality-book"
quality_book.icon = "__quality-upgrade-planner__/graphics/icons/quality-book.png"
quality_book.hidden_in_factoriopedia = true
table.insert(quality_book.flags, "only-in-cursor")

data:extend{
  quality_book,
  {
    type = "custom-input",
    name = "get-quality-book",
    key_sequence = "CONTROL + U",
    action = "lua",
  },
  {
    type = "shortcut",
    name = "get-quality-book",
    icon = "__quality-upgrade-planner__/graphics/icons/gear.png",
    icon_size = 128,
    small_icon = "__quality-upgrade-planner__/graphics/icons/gear.png",
    small_icon_size = 128,
    action = "lua",
    associated_control_input = "get-quality-book",
  },
}
