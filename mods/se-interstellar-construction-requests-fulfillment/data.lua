local turret = table.deepcopy(data.raw['ammo-turret']['se-meteor-point-defence-container'])
turret.type = 'electric-turret'
turret.name = 'se-interstellar-construction-requests-fulfillment--turret'

local tint = {r=244, g=209, b=6}
turret.base_picture.layers[2].tint = tint
turret.base_picture.layers[2].hr_version.tint = tint

turret.icon = nil
turret.icons = table.deepcopy(data.raw['item']['se-meteor-point-defence'].icons)
turret.icons[2].tint = tint

turret.energy_source = {
  buffer_capacity = "4GJ",
  input_flow_limit = "0.1GW",
  type = "electric",
  usage_priority = "primary-input"
}

turret.attack_parameters = {
  ammo_type = {
    category = "se-meteor-defence",
    energy_consumption = "1GJ",
  },
  range = 1,
  cooldown = 1,
  type = "beam",
}

turret.localised_name = nil
turret.localised_description = nil

--

local item = {
  type = 'item',
  name = 'se-interstellar-construction-requests-fulfillment--item',
  order = 'k-a', -- weapon delivery cannon is `j-`
  subgroup = 'surface-defense',
  stack_size = 50,
  flags = {'draw-logistic-overlay'},
}

item.icons = table.deepcopy(data.raw['item']['se-meteor-point-defence']).icons
item.icons[2].tint = tint

item.place_result = turret.name
turret.minable.result = item.name

--

local recipe = {
  type = 'recipe',
  name = 'se-interstellar-construction-requests-fulfillment--recipe',
  result = 'se-interstellar-construction-requests-fulfillment--item',
  enabled = false,
  energy_required = 5,
  ingredients = {
    { 'se-meteor-point-defence', 1 },
    { 'sulfur', 12 },
  },
  requester_paste_multiplier = 1,
  always_show_made_in = false,
}

--

local technology = {
  type = "technology",
  name = 'se-interstellar-construction-requests-fulfillment--technology',
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

technology.icons = table.deepcopy(data.raw['technology']['se-meteor-point-defence']).icons
technology.icons[2].tint = tint

data:extend({turret, item, recipe, technology})
