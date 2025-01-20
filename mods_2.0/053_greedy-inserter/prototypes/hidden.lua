local function selection_box_square(range)
  return {{-range, -range}, {range, range}}
end

local container = {
  type = "container",
  name = "greedy-container",

  selection_priority = 51,
  selection_box = selection_box_square(0.3),
  collision_box = table.deepcopy(data.raw["container"]["wooden-chest"].collision_box),
  collision_mask = {layers = {}},

  flags = {"not-on-map", "no-automated-item-removal", "no-automated-item-insertion"},

  inventory_size = 1,
  selectable_in_game = false,
  hidden = true,
}

local recipe = {
  type = "recipe",
  name = "greedy-repair-pack",
  icons = {
    {icon = data.raw["item"]["greedy-inserter"].icon},
    {icon = data.raw["repair-tool"]["repair-pack"].icon, scale = 0.25},
  },
  enabled = true,
  ingredients = {
    {type = "item", name = "repair-pack", amount = 1},
  },
  results = {},
  hidden = true,
  energy_required = 1/(60*2),
}

data:extend({container, recipe})
