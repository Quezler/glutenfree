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

-- swap the two recipes, causing machines already crafting it when the mod was installed to receive that red circle stripe thing.
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

-- log(serpent.block(holmium_chemical_plant.fluid_boxes))

local holmium_solution_fluid = data.raw["fluid"]["holmium-solution"]

local holmium_solution_item = {
  type = "item",
  name = "holmium-solution-quality-multiplier",
  localised_description = {"", "[font=default-bold]",
    "[img=quality/normal] × 1\n",
    "[img=quality/uncommon] × 4\n",
    "[img=quality/rare] × 16\n",
    "[img=quality/epic] × 64\n",
    "[img=quality/legendary] × 256",
  "[/font]"},
  icon = "__core__/graphics/empty.png",
  stack_size = 1,
  flags = {"only-in-cursor", "not-stackable", "spawnable"},
  hidden = true,
}
data:extend{holmium_solution_item}

quality_holmium_solution_recipe.results = {
  {type = "item", name="holmium-solution-quality-multiplier", amount = 1, ignored_by_stats = 1},
  {type = "fluid", name="holmium-solution", amount = 100},
}
