local item = {
  type = "item",
  name = mod_prefix .. "a-whole-bunch-of-items",
  icon = "__core__/graphics/empty.png",
  icon_size = 1,
  stack_size = 1,
  flags = {"not-stackable", "only-in-cursor"},
  hidden = true,
}

local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "recipe-category",
}

local recipe = {
  type = "recipe",
  name = mod_prefix .. "a-whole-bunch-of-items",
  icon = "__core__/graphics/empty.png",
  icon_size = 1,
  category = recipe_category.name,
  enabled = true,
  auto_recycle = false,
  energy_required = 40,
  ingredients = {{type = "item", name = item.name, amount = 1}},
  results = {},
  hide_from_player_crafting = true,
  hidden_in_factoriopedia = true,
}

data:extend{item, recipe_category, recipe}
