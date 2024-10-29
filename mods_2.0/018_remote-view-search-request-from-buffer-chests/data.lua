local icon = "__remote-view-search-request-from-buffer-chests__/graphics/icons/request-from-buffer-chests.png"

local category = {
  type = "recipe-category",
  name = "request-from-buffer-chests",
}

local recipe = {
  type = "recipe",
  name = "request-from-buffer-chests",

  localised_name = {"gui-logistic.request-from-buffer-chests"},
  icon = icon,
  hidden_from_player_crafting = true,
  hidden_in_factoriopedia = true,
  energy_required = 1,

  category = category.name,
}

local assembler = {
  type = "assembling-machine",
  name = "request-from-buffer-chests",

  localised_name = {"gui-logistic.request-from-buffer-chests"},
  icon = icon,

  fixed_recipe = recipe.name,

  collision_mask = {layers = {}},
  collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  selectable_in_game = false,

  energy_usage = "1kW",
  energy_source = {type = "void"},
  crafting_speed = 1,
  crafting_categories = {category.name},

  flags = {
    "not-on-map",
    "hide-alt-info",
    "no-automated-item-removal",
    "no-automated-item-insertion",
  }
}

data:extend{category, recipe, assembler}
