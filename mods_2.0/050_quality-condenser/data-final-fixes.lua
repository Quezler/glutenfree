require("shared")

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
