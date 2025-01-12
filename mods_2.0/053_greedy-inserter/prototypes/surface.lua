data:extend{{
  type = "planet",
  name = "greedy-inserter",
  icon = "__greedy-inserter__/graphics/icons/greedy-inserter.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

local recipe_category = {
  type = "recipe-category",
  name = "greedy-inserter--recipe-category",
}

local recipe = {
  type = "recipe",
  name = "greedy-inserter--recipe",
  enabled = true,
  category = recipe_category.name,
  ingredients = {{type = "item", name = "blueprint", amount = 1}},
  results     = {{type = "item", name = "blueprint", amount = 1}},
  hidden = true,
  energy_required = 1,
}

local assembling_machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
assembling_machine.name = "greedy-inserter--assembling-machine"
assembling_machine.vector_to_place_result = {-0.5, 2}
assembling_machine.crafting_categories = {recipe_category.name}
assembling_machine.hidden = true
assembling_machine.fixed_recipe = recipe.name
assembling_machine.crafting_speed = 60
assembling_machine.energy_source = {type = "void"}

data:extend({recipe_category, recipe, assembling_machine})
