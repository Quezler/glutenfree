require("shared")

if mods["base"] and washbox_debug then
  data:extend{{
    type = "recipe",
    name = "washbox--barrel-to-water-barrel",
    localised_name = {"recipe-name.fill-barrel", {"fluid-name.water"}},
    icons = data.raw["recipe"]["water-barrel"].icons,

    enabled = true,
    category = "washbox",
    energy_required = 1,

    ingredients = {
      { type = "item", name = "barrel", amount = 1 },
      { type = "fluid", name = "water", amount = 100 },
    },

    results = {
      { type = "item", name = "water-barrel", amount = 1 },
      { type = "fluid", name = "water", amount = 0 },
    },

    crafting_machine_tint = {
      primary = {r=000, g=145, b=255, a=127}, -- https://mods.factorio.com/mod/Automatic_Train_Painter > Factorio > water
    }
  }}

  data:extend{{
    type = "recipe",
    name = "washbox--water-barrel-to-barrel",
    localised_name = {"recipe-name.empty-filled-barrel", {"fluid-name.water"}},
    icons = data.raw["recipe"]["empty-water-barrel"].icons,

    enabled = true,
    category = "washbox",
    energy_required = 1,

    ingredients = {
      { type = "item", name = "water-barrel", amount = 1 },
      { type = "fluid", name = "water", amount = 100 },
    },

    results = {
      { type = "item", name = "barrel", amount = 1 },
      { type = "fluid", name = "water", amount = 200 },
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
      { type = "fluid", name = "water", amount = 100 },
    },

    results = {
      { type = "item", name = "kr-pollution-filter", amount = 1 },
      { type = "fluid", name = "water", amount = 50 },
    },

    crafting_machine_tint = {
      primary = {r=000, g=145, b=255, a=127}, -- https://mods.factorio.com/mod/Automatic_Train_Painter > Factorio > water
    }
  }}

  table.insert(data.raw["technology"]["kr-air-purification"].effects, {
    type = "unlock-recipe", recipe = mod_prefix .. "kr-restore-used-pollution-filter",
  })
end
