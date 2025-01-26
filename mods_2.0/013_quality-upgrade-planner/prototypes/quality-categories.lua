local shared = require("shared")

for _, quality_category in ipairs(shared.quality_categories) do
  data:extend{{
    type = "sprite",
    name = "quality-category-" .. quality_category.name,
    filename = "__quality-upgrade-planner__/graphics/icons/quality-category/" .. quality_category.name .. ".png",
    width = 64,
    height = 64,
    flags = {"icon"},
  }}
end
