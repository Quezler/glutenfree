require("shared")

local debug = false

if debug then
  data:extend{{
    type = "recipe",
    name = "washbox--iron-plate-to-copper-plate",
    icon = "__base__/graphics/icons/electric-mining-drill.png",

    enabled = true,
    category = "washbox",
    energy_required = 1,

    ingredients = {
      { type = "item", name = "iron-plate", amount = 1 },
      { type = "fluid", name = "water", amount = 50 },
    },

    results = {
      { type = "item", name = "copper-plate", amount = 1 },
      { type = "fluid", name = "water", amount = 25 },
    },

    crafting_machine_tint = {
      primary = {r=000, g=145, b=255, a=127}, -- https://mods.factorio.com/mod/Automatic_Train_Painter > Factorio > water
    }
  }}
end

if data.raw["item"]["kr-used-pollution-filter"] and data.raw["item"]["kr-pollution-filter"] and data.raw["technology"]["kr-air-purification"] then
  data:extend{{
    type = "recipe",
    name = mod_prefix .. "kr-restore-used-pollution-filter",
    localised_name = {"recipe-name.kr-restore-used-pollution-filter"},
    icon = "__Krastorio2Assets__/icons/recipes/restore-used-pollution-filter.png",
    icon_size = 128,

    enabled = false,
    category = "washbox",
    energy_required = 10,

    ingredients = {
      { type = "item", name = "kr-used-pollution-filter", amount = 1 },
      { type = "fluid", name = "water", amount = 50 },
    },

    results = {
      { type = "item", name = "kr-pollution-filter", amount = 1 },
      { type = "fluid", name = "water", amount = 25 },
    },

    crafting_machine_tint = {
      primary = {r=000, g=145, b=255, a=127}, -- https://mods.factorio.com/mod/Automatic_Train_Painter > Factorio > water
    }
  }}

  table.insert(data.raw["technology"]["kr-air-purification"].effects, {
    type = "unlock-recipe", recipe = mod_prefix .. "kr-restore-used-pollution-filter",
  })
end
