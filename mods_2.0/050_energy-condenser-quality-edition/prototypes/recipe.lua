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
  name = mod_prefix .. "recipe",
  -- icons = {
  --   {
  --     icon = mod_directory .. "/graphics/icons/recycling.png"
  --   },
  --   {
  --     icon = data.raw["assembling-machine"][mod_prefix .. "crafter"].icon,
  --     scale = 0.4
  --   },
  --   {
  --     icon = mod_directory .. "/graphics/icons/recycling-top.png"
  --   }
  -- },
  icon = data.raw["assembling-machine"][mod_prefix .. "crafter"].icon,
  category = recipe_category.name,
  enabled = true,
  auto_recycle = false,
  energy_required = 30,
  ingredients = {{type = "item", name = "repair-pack", amount = 1}},
  results = {},
  hidden = true,
}

data:extend{recipe_category, recipe}
