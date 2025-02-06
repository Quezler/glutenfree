require("shared")

local quality = -20

table.insert(data.raw["technology"]["automation-science-pack"].effects, {
  type = "nothing",
  icons = {
    {icon = data.raw["assembling-machine"][mod_prefix .. "crafter"].icon},
    {icon = "__core__/graphics/icons/any-quality.png", shift = {8, 8}, scale = 0.25},
  },
  mod_prefix .. "automation-science-pack",
  effect_description = {"effect-description.quality-condenser-quality", quality > 0 and "+" or "", tostring(quality)}
})
