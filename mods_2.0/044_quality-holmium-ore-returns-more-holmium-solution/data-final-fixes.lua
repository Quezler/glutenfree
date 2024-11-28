local Shared = require("shared")

local lines = {}
for _, quality in pairs(data.raw["quality"]) do
  if not quality.hidden then
    table.insert(lines, string.format("[img=quality/%s] × %d", quality.name, Shared.get_multiplier_for_quality(quality)))
  end
end
data.raw["item"]["holmium-solution-quality-based-productivity"].localised_description = {"", "[font=default-bold]", table.concat(lines, "\n"), "[/font]"}
