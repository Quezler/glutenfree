for _, quality in pairs(data.raw["quality"]) do
  local planner = table.deepcopy(data.raw["selection-tool"]["quality-upgrade-planner"])
  planner.name = quality.name .. "-" .. planner.name
  planner.icons[1] = {icon = "__quality-upgrade-planner__/graphics/icons/quality-upgrade-planner-mask.png", tint = quality.color}
  data:extend{planner}
end
