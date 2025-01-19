local function selection_box_square(range)
  return {{-range, -range}, {range, range}}
end

local container = {
  type = "container",
  name = "greedy-inserter--container",

  selection_priority = 51,
  selection_box = selection_box_square(0.25),
  collision_box = table.deepcopy(data.raw["container"]["wooden-chest"].collision_box),
  collision_mask = {layers = {}},

  flags = {"not-on-map", "no-automated-item-removal", "no-automated-item-insertion"},

  inventory_size = 100,
  selectable_in_game = false,
  hidden = true,
}

data:extend({container})

local fuel_category = {
  type = "fuel-category",
  name = "greedy-inserter--fuel-category",
}

local fuel = {
  type = "tool",
  name = "greedy-inserter--fuel",
  icon = "__base__/graphics/icons/compilatron.png",

  fuel_category = fuel_category.name,
  fuel_value = "1GJ",
  stack_size = 1,
  durability = 1,

  flags = {"only-in-cursor", "not-stackable", "spawnable"},
  hidden = true,
}

data:extend({fuel_category, fuel})

data.raw["inserter"]["greedy-inserter"].energy_source.fuel_categories = {fuel_category.name}
data.raw["inserter"]["greedy-inserter"].energy_source.initial_fuel = fuel.name
data.raw["inserter"]["greedy-inserter"].energy_source.initial_fuel_percent = 1
