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

-- holmium_chemical_plant.fixed_recipe = quality_holmium_solution_recipe.name
-- holmium_chemical_plant.fixed_quality = "normal"

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

for _, fluid_box in ipairs(holmium_chemical_plant.fluid_boxes) do
  if fluid_box.production_type == "input" then
    fluid_box.filter = "water"
  end
  if fluid_box.production_type == "output" then
    fluid_box.filter = "holmium-solution"
    -- fluid_box.production_type = "none"
    fluid_box.production_type = "input"
    -- fluid_box.pipe_covers = nil
    -- fluid_box.pipe_covers_frozen = nil
  end
  -- fluid_box.hide_connection_info = true
  -- for _, connection in ipairs(fluid_box.pipe_connections) do
    -- connection.connection_category = "holmium-chemical-plant." .. tostring(math.random(1, 1000000))
  -- end
end

local holmium_solution_fluid = data.raw["fluid"]["holmium-solution"]

local holmium_solution_item = {
  type = "item",
  name = "holmium-solution",
  localised_name = {"fluid-name." .. holmium_solution_fluid.name},
  icon = holmium_solution_fluid.icon,
  stack_size = 100,
  flags = {"only-in-cursor"},
  weight = 1 * tons + 1,
  hidden = true,
}
data:extend{holmium_solution_item}

quality_holmium_solution_recipe.results = {{type = "item", name="holmium-solution", amount = 100}}

quality_holmium_solution_recipe.ingredients =
{
  {type = "item", name = "holmium-ore", amount = 2},
  {type = "item", name = "stone", amount = 1},
  {type = "fluid", name="water", amount = 10, fluidbox_index = 1}
}
