local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "recipe-category",
}

local seconds = 2 -- math constant

local recipe = {
  type = "recipe",
  name = mod_prefix .. "recipe",
  -- icon = mod_directory .. "/graphics/research-center/research-center-icon.png",
  icon = mod_directory .. "/graphics/icons/recipe.png",
  icon_size = 144,
  category = recipe_category.name,
  enabled = true,
  auto_recycle = false,
  energy_required = 10 * seconds,
  ingredients = {},
  results = {},
  hide_from_player_crafting = true,
  hidden_in_factoriopedia = true,
}

data:extend{recipe_category, recipe}
