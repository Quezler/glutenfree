-- uncomment only to generate a fancy recycling icon, the quality mod itself remains an optional dependency
-- require("__quality__.prototypes.recycling")
-- error(serpent.block(generate_recycling_recipe_icons_from_item({
--   icon = "__core__/graphics/icons/any-quality.png",
-- })))

local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "recipe-category",
}

local recipe = {
  type = "recipe",
  name = mod_prefix .. "any-quality",
  localised_name = {"virtual-signal-name.signal-any-quality"},
  icons = {
    {
      icon = mod_directory .. "/graphics/icons/recycling.png"
    },
    {
      icon = "__core__/graphics/icons/any-quality.png",
      scale = 0.4
    },
    {
      icon = mod_directory .. "/graphics/icons/recycling-top.png"
    }
  },
  category = recipe_category.name,
  enabled = false,
  auto_recycle = false,
  energy_required = 30,
  ingredients = {{type = "item", name = "scrap", amount = 1}},
  results = {},
  hidden = true,
}

data:extend{recipe_category, recipe}
