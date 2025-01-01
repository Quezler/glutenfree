
local mod_prefix = "rocket-silos-can-buffer-more-rockets--"

local multiplier = settings.startup[mod_prefix .. "rocket-parts-storage-cap-multiplier"].value

local rocket_silo = data.raw["rocket-silo"]["rocket-silo"]
rocket_silo.rocket_parts_storage_cap = rocket_silo.rocket_parts_required * multiplier

if mods["QualityRockets"] then
  local function get_storage_cap_for_quality(quality)
    local formula = settings.startup[mod_prefix .. "quality-rockets-multiplier-math"].value
    local number = load("return " .. formula, "get_storage_cap_for_quality", "t", {quality = quality, math = math, multiplier = multiplier})()
    return number
  end

  rocket_silo.rocket_parts_storage_cap = get_storage_cap_for_quality(data.raw["quality"]["normal"])

  for _, quality in pairs(data.raw["quality"]) do
    local silo = data.raw["rocket-silo"][quality.name .. "-rocket-silo"]
    if silo then
      rocket_silo.rocket_parts_storage_cap = get_storage_cap_for_quality(quality)
    end
  end
end
