local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "recipe-category",
}

local recipe = {
  type = "recipe",
  name = mod_prefix .. "recipe",
  icon = "__core__/graphics/empty.png",
  icon_size = 1,
  category = recipe_category.name,
  enabled = true,
  auto_recycle = false,
  energy_required = 30,
  ingredients = {{type = "item", name = "repair-pack", amount = 1}},
  results = {},
  hide_from_player_crafting = true,
  hidden_in_factoriopedia = true,
}

data:extend{recipe_category, recipe}
