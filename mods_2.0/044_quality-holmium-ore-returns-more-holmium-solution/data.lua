local holmium_chemical_plant = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
local holmium_chemical_plant_item = table.deepcopy(data.raw["item"]["chemical-plant"])

holmium_chemical_plant.name = "holmium-chemical-plant"
holmium_chemical_plant_item.name = holmium_chemical_plant.name

holmium_chemical_plant.minable.result = holmium_chemical_plant_item.name
holmium_chemical_plant_item.place_result = holmium_chemical_plant.name

holmium_chemical_plant.icon = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/icons/holmium-chemical-plant.png"
holmium_chemical_plant_item.icon = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/icons/holmium-chemical-plant.png"

holmium_chemical_plant.graphics_set.animation = make_4way_animation_from_spritesheet({layers =
{
  {
    filename = "__quality-holmium-ore-returns-more-holmium-solution__/graphics/entity/holmium-chemical-plant/holmium-chemical-plant.png",
    width = 220,
    height = 292,
    frame_count = 24,
    line_length = 12,
    shift = util.by_pixel(0.5, -9),
    scale = 0.5
  },
  {
    filename = "__base__/graphics/entity/chemical-plant/chemical-plant-shadow.png",
    width = 312,
    height = 222,
    repeat_count = 24,
    shift = util.by_pixel(27, 6),
    draw_as_shadow = true,
    scale = 0.5
  }
}})

local holmium_chemistry_category = {
  type = "recipe-category",
  name = "holmium-chemistry"
}

local holmium_solution_recipe = data.raw["recipe"]["holmium-solution"]
local holmium_processing = data.raw["technology"]["holmium-processing"]

for _, effect in ipairs(holmium_processing.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "holmium-solution" then
    effect.recipe = "quality-holmium-solution"
  end
end

local quality_holmium_solution_recipe = table.deepcopy(holmium_solution_recipe)
quality_holmium_solution_recipe.name = "quality-holmium-solution"
quality_holmium_solution_recipe.localised_name = {"fluid-name." .. holmium_solution_recipe.name}
quality_holmium_solution_recipe.category = holmium_chemistry_category.name

holmium_chemical_plant.crafting_categories = {holmium_chemistry_category.name}

quality_holmium_solution_recipe.icon = nil
quality_holmium_solution_recipe.icons = {
  {icon = data.raw["fluid"]["holmium-solution"].icon},
  {icon = data.raw["virtual-signal"]["signal-any-quality"].icon, scale = 0.25, shift = {-8, 8}},
}

holmium_chemical_plant.fixed_recipe = quality_holmium_solution_recipe.name
holmium_chemical_plant.fixed_quality = "normal"

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
  holmium_chemical_plant,
  holmium_chemical_plant_item,
  holmium_chemical_plant_recipe,
  holmium_chemistry_category,
  quality_holmium_solution_recipe,
}
