-- mod_name = "quality-condenser"
-- mod_prefix = mod_name .. "--"
-- mod_directory = "__" .. mod_name .. "__"

-- todo: rename mod
mod_prefix = "quality-condenser--"
mod_directory = "__energy-condenser-quality-edition__"

function get_base_quality(quality)
  local formula = mods and settings.startup[mod_prefix .. "base-quality"].value or settings.startup[mod_prefix .. "base-quality"].value
  local number = load("return " .. formula, "get_base_quality", "t", {quality = quality, math = math})()
  return math.floor(number * 10)
end
