local quality_book = table.deepcopy(data.raw["blueprint-book"]["blueprint-book"])

quality_book.name = "quality-book"
quality_book.icon = "__quality-upgrade-planner__/graphics/icons/quality-book.png"
table.insert(quality_book.flags, "only-in-cursor")

data:extend{quality_book}
