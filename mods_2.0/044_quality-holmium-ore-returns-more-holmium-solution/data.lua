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

table.insert(holmium_chemical_plant.fluid_boxes[3].pipe_connections, { flow_direction = "input", connection_type = "linked", linked_connection_id = 3 })
table.insert(holmium_chemical_plant.fluid_boxes[4].pipe_connections, { flow_direction = "input", connection_type = "linked", linked_connection_id = 4 })

local holmium_solution_fluid = data.raw["fluid"]["holmium-solution"]

local holmium_solution_item = {
  type = "item",
  name = "holmium-solution-quality-based-productivity",
  localised_description = nil, -- set in data-final-fixes.lua
  icons = {
    {draw_background = true, icon = holmium_solution_fluid.icon, scale = 0.375},
    {icon = "__core__/graphics/icons/technology/effect-constant/effect-constant-recipe-productivity.png"}
  },
  stack_size = 1,
  flags = {"only-in-cursor", "not-stackable", "spawnable"},
  hidden = true,
}
data:extend{holmium_solution_item}

quality_holmium_solution_recipe.results = {
  {type = "item", name="holmium-solution-quality-based-productivity", amount = 1},
  {type = "fluid", name="holmium-solution", amount = 100},
}

data:extend{{
  type = "planet",
  name = "holmium-chemical-plant",
  icon = holmium_chemical_plant.icon,

  distance = 0,
  orientation = 0,

  hidden = true,
}}

data:extend{{
  type = "item",
  name = "coupon-for-holmium-solution",

  icons = {
    {icon = data.raw["item"]["coin"].icon},
    {icon = holmium_solution_fluid.icon, scale = 0.375}
  },
  stack_size = 10,
  flags = {"only-in-cursor"},

  hidden = true,
}}

table.insert(holmium_chemical_plant.flags, "no-automated-item-removal")

local fast_inserter = table.deepcopy(data.raw["inserter"]["fast-inserter"])
local inserter = {
  type = "inserter",
  name = "holmium-chemical-plant-inserter",

  extension_speed = fast_inserter.extension_speed * 10,
  rotation_speed  = fast_inserter.rotation_speed  * 10,
  insert_position = fast_inserter.insert_position,
  pickup_position = fast_inserter.pickup_position,
  stack_size_bonus = 10,

  selection_box = fast_inserter.selection_box,
  collision_box = fast_inserter.collision_box,
  collision_mask = {layers = {}},
  selection_priority = 51,
  selectable_in_game = false,
  flags = {"not-on-map"},
  energy_source = {type = "void"},
  draw_inserter_arrow = false,
  filter_count = 1,
  draw_held_item = false,
  circuit_wire_max_distance = 9,
  hidden = true,
}
data:extend{inserter}
