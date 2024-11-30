local Shared = {}

local multiplier_math_setting_name = "quality-holmium-ore-returns-more-holmium-solution--multiplier-math"

function Shared.get_multiplier_for_quality(quality)
  local formula = mods and settings.startup[multiplier_math_setting_name].value or settings.startup[multiplier_math_setting_name].value
  local number = load("return " .. formula, "get_multiplier_for_quality", "t", {quality = quality, math = math})()
  return number
end

return Shared
