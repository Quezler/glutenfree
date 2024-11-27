local Entity = require("prototypes.entity")

local holmium_solution_recipe = table.deepcopy(data.raw["recipe"]["holmium-solution"])

local recipe_category = {
  type = "recipe-category",
  name = "quality-holmium-solution",
}

-- data.raw["recipe"]["holmium-solution"].category = recipe_category.name

data:extend{recipe_category}

holmium_solution_recipe.localised_name = {"fluid-name." .. holmium_solution_recipe.name}
holmium_solution_recipe.category = recipe_category.name

for _, quality in pairs(data.raw["quality"]) do
  local quality_holmium_solution_recipe = table.deepcopy(holmium_solution_recipe)
  quality_holmium_solution_recipe.name = quality.name .. "-quality-holmium-solution"
  assert(#quality_holmium_solution_recipe.results == 1)
  quality_holmium_solution_recipe.results[1].amount = quality_holmium_solution_recipe.results[1].amount * quality.level
  quality_holmium_solution_recipe.hidden = true
  data:extend{quality_holmium_solution_recipe}

  local entity = Entity.new_holmium_chemical_plant(quality)
  entity.fixed_recipe = quality_holmium_solution_recipe.name
  entity.fixed_quality = quality.name
  entity.crafting_categories = {recipe_category.name}
  entity.hidden = true
  data:extend{entity}
end
