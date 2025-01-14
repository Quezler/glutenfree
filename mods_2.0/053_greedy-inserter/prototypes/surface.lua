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
  icon = data.raw["repair-tool"]["repair-pack"].icon,
  enabled = true,
  category = recipe_category.name,
  ingredients = {
    {type = "item", name = "repair-pack", amount = 1},
  },
  results = {},
  hidden = true,
  energy_required = 1,
}

local assembling_machine = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
assembling_machine.name = "greedy-inserter--assembling-machine"
assembling_machine.crafting_categories = {recipe_category.name}
assembling_machine.hidden = true
assembling_machine.fixed_recipe = recipe.name
assembling_machine.crafting_speed = 60
assembling_machine.energy_source = {type = "void"}

local container = {
  type = "container",
  name = "greedy-inserter--container",

  selection_priority = 51,
  selection_box = table.deepcopy(data.raw["container"]["wooden-chest"].selection_box),
  collision_box = table.deepcopy(data.raw["container"]["wooden-chest"].collision_box),
  collision_mask = {layers = {}},

  flags = {"not-on-map", "no-automated-item-removal", "no-automated-item-insertion"},

  inventory_size = 1,
  selectable_in_game = false,
  hidden = true,
}

data:extend({recipe_category, recipe, assembling_machine, container})

local fuel = {
  type = "tool",
  name = "greedy-inserter--compiltron",
  icon = "__base__/graphics/icons/compilatron.png",

  fuel_category = "chemical",
  fuel_value = "4kJ", -- this needs to slightly less than what half a rotation takes (based on both energy_per_rotation & energy_per_movement)
  stack_size = 1,
  durability = 1,

  flags = {"only-in-cursor", "not-stackable", "spawnable"},
  hidden = true,
}

data:extend({fuel})
