local tint = {r=244, g=209, b=6}

local buffer_chest = table.deepcopy(data.raw["logistic-container"]["buffer-chest"])
buffer_chest.name = "interstellar-construction-turret--buffer-chest"

buffer_chest.selection_box = {{-1.50, -1.50}, { 1.50,  1.50}}
buffer_chest.collision_box = {{-1.35, -1.35}, { 1.35,  1.35}}
buffer_chest.drawing_box_vertical_extension = 2.85

buffer_chest.icon = nil
buffer_chest.icons = table.deepcopy(data.raw["item"]["se-meteor-point-defence"].icons)
buffer_chest.icons[2].tint = tint

buffer_chest.animation = table.deepcopy(data.raw["ammo-turret"]["se-meteor-point-defence-container"].graphics_set.base_visualisation.animation.north)
buffer_chest.animation.layers[2].tint = tint

buffer_chest.inventory_size = 30
buffer_chest.inventory_type = "normal"

buffer_chest.circuit_connector = nil
buffer_chest.circuit_wire_max_distance = nil
buffer_chest.corpse = "medium-remnants"
buffer_chest.dying_explosion = "medium-explosion"
buffer_chest.fast_replaceable_group = nil
buffer_chest.max_health = 2000
buffer_chest.resistances = {
  { type = "impact", percent = 100 },
  { type = "fire"  , percent = 100 },
}

table.insert(buffer_chest.flags, "hide-alt-info")
table.insert(buffer_chest.flags, "no-automated-item-removal")
table.insert(buffer_chest.flags, "no-automated-item-insertion")

-- log(serpent.block(buffer_chest))

--

local item = {
  type = "item",
  name = "se-interstellar-construction-requests-fulfillment--item",
  order = "k-a", -- weapon delivery cannon is `j-`
  subgroup = "surface-defense",
  stack_size = 50,
  flags = {"draw-logistic-overlay"},
}

item.icons = table.deepcopy(data.raw["item"]["se-meteor-point-defence"]).icons
item.icons[2].tint = tint

item.place_result = buffer_chest.name
buffer_chest.minable.result = item.name

--

local recipe = {
  type = "recipe",
  name = "se-interstellar-construction-requests-fulfillment--recipe",
  enabled = false,
  energy_required = 5,
  ingredients = {
    {type = "item", name = "se-meteor-point-defence", amount = 1},
    {type = "item", name = "sulfur", amount = 12},
  },
  results = {{type = "item", name = item.name, amount = 1}},
  requester_paste_multiplier = 1,
  always_show_made_in = false,
}

--

local technology = {
  type = "technology",
  name = "se-interstellar-construction-requests-fulfillment--technology",
  effects = {
    { type = "unlock-recipe", recipe = recipe.name }
  },
  order = "e-h",
  prerequisites = {
    "se-meteor-point-defence",
    "construction-robotics",
    "space-science-pack",
  },
  unit = {
    count = 250,
    ingredients = {
      { "automation-science-pack", 1 },
      { "logistic-science-pack"  , 1 },
      { "chemical-science-pack"  , 1 },
      { "se-rocket-science-pack" , 1 },
      { "space-science-pack"     , 1 },
    },
    time = 30
  }
}

technology.icons = table.deepcopy(data.raw["technology"]["se-meteor-point-defence"]).icons
technology.icons[2].tint = tint

--

data:extend({buffer_chest, item, recipe, technology})
