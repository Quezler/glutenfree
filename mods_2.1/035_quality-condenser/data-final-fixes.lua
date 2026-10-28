package.loaded["__quality-condenser__/shared.lua"] = nil
require("shared")

-- mods like module-category-defaults restrict the module categories, which also blocks the beacon interface modules
local crafter_entity = data.raw["assembling-machine"][mod_name]
if crafter_entity.allowed_module_categories then
  local beacon_interface_category = "beacon-interface--module-category"
  local found = false
  for _, category in ipairs(crafter_entity.allowed_module_categories) do
    if category == beacon_interface_category then found = true end
  end
  if not found then
    table.insert(crafter_entity.allowed_module_categories, beacon_interface_category)
  end
end

local function string_split(s, delimiter)
  if s == "" then return {} end
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
  end
  return result
end

local parts = settings.startup[mod_prefix .. "technology-effects"].value or "" --[[@as string]]
for _, part in ipairs(string_split(parts, ",")) do
  local technology_name, quality_modifier = table.unpack(string_split(part, "="))

  assert(data.raw["technology"][technology_name], string.format("unknown technology: %s", technology_name))

  table.insert(data.raw["technology"][technology_name].effects, {
    type = "nothing",
    icons = {
      {icon = data.raw["assembling-machine"][mod_name].icon},
      {icon = "__core__/graphics/icons/any-quality.png", shift = {8, 8}, scale = 0.25},
    },
    effect_description = {"effect-description.quality-condenser-quality", tonumber(quality_modifier) > 0 and "+" or "", quality_modifier}
  })
end
