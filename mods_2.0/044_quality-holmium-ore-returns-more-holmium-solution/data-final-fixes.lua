local Entity = require("prototypes.entity")

local holmium_solution_recipe = table.deepcopy(data.raw["recipe"]["holmium-solution"])

local recipe_category = {
  type = "recipe-category",
  name = "quality-holmium-solution",
}

data:extend{recipe_category}

holmium_solution_recipe.localised_name = {"fluid-name." .. holmium_solution_recipe.name}
holmium_solution_recipe.category = recipe_category.name

for _, quality in pairs(data.raw["quality"]) do
  if quality.name ~= "quality-unknown" then
    local quality_holmium_solution_recipe = table.deepcopy(holmium_solution_recipe)
    quality_holmium_solution_recipe.name = quality.name .. "-quality-holmium-solution"
    -- quality_holmium_solution_recipe.name = string.format("%squality-holmium-solution", quality.name ~= "normal" and quality.name .. "-" or "")
    -- log(quality_holmium_solution_recipe.name)
    assert(#quality_holmium_solution_recipe.results == 1)
    quality_holmium_solution_recipe.results[1].amount = quality_holmium_solution_recipe.results[1].amount * (quality.level + 1)
    -- log(serpent.block(quality_holmium_solution_recipe.results))
    quality_holmium_solution_recipe.hidden = true
    data:extend{quality_holmium_solution_recipe}

    local entity = Entity.new_holmium_chemical_plant(quality)
    entity.fixed_recipe = quality_holmium_solution_recipe.name
    entity.fixed_quality = quality.name
    entity.crafting_categories = {recipe_category.name}
    entity.hidden = quality.name ~= "normal" and true or false
    entity.placeable_by = {item = "holmium-chemical-plant", count = 1}
    data:extend{entity}
  end
end

data.raw["recipe"]["holmium-solution"].hidden = true
-- local visible_recipe = table.deepcopy(holmium_solution_recipe)
-- data:extend{visible_recipe}
