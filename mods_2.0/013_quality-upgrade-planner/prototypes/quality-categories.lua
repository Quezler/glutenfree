local shared = require("shared")

for _, quality_category in ipairs(shared.quality_categories) do
  data:extend{{
    type = "sprite",
    name = "quality-category-" .. quality_category,
    filename = "__quality-upgrade-planner__/graphics/icons/quality-category/" .. quality_category .. ".png",
    width = 64,
    height = 64,
    flags = {"icon"},
  }}
end
