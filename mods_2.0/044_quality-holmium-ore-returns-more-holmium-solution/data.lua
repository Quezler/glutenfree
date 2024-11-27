local holmium_chemical_plant_item = table.deepcopy(data.raw["item"]["chemical-plant"])

holmium_chemical_plant_item.name = "holmium-chemical-plant"
holmium_chemical_plant_item.place_result = "quality-unknown-holmium-chemical-plant"
holmium_chemical_plant_item.icon = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/icons/holmium-chemical-plant.png"

local holmium_solution_recipe = data.raw["recipe"]["holmium-solution"]
local holmium_processing = data.raw["technology"]["holmium-processing"]

for _, effect in ipairs(holmium_processing.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "holmium-solution" then
    effect.recipe = "quality-holmium-solution"
  end
end

-- notice: actual category is in data-final-fixes
local recipe_category = {
  type = "recipe-category",
  name = "quality-holmium-solution",
}

local quality_holmium_solution_recipe = table.deepcopy(holmium_solution_recipe)
quality_holmium_solution_recipe.name = "quality-holmium-solution"
quality_holmium_solution_recipe.localised_name = {"fluid-name." .. holmium_solution_recipe.name}
quality_holmium_solution_recipe.category = recipe_category.name

local holmium_chemical_plant_recipe = {
  type = "recipe",
  name = holmium_chemical_plant_item.name,
  energy_required = 10,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "repair-pack", amount = 1},
    {type = "item", name = "holmium-ore", amount = 1},
    {type = "item", name = "chemical-plant", amount = 1},
  },
  results = {{type="item", name=holmium_chemical_plant_item.name, amount=1}}
}

table.insert(holmium_processing.effects, 1, {
  type = "unlock-recipe",
  recipe = holmium_chemical_plant_recipe.name,
})

data:extend{
  holmium_chemical_plant_item,
  holmium_chemical_plant_recipe,
  quality_holmium_solution_recipe,
}
