require('util')

local entity = table.deepcopy(data.raw['logistic-container']['buffer-chest'])
entity.name = 'fulgoran-construction-hub'

local market = data.raw['market']['market']

entity.selection_box = market.selection_box
entity.collision_box = market.collision_box

entity.icon = '__fulgora-linked-construction-hub__/graphics/icons/fulgoran-construction-hub.png'
entity.icons = nil -- aai containers
entity.animation = table.deepcopy(market.picture)
entity.animation.filename = '__fulgora-linked-construction-hub__/graphics/entity/fulgoran-construction-hub.png'

entity.inventory_type = "normal"

entity.circuit_wire_connection_point = nil
entity.circuit_wire_max_distance = nil
entity.fast_replaceable_group = nil

entity.corpse = market.corpse
entity.dying_explosion = market.dying_explosion -- nil

table.insert(entity.flags, 'no-automated-item-removal')
table.insert(entity.flags, 'no-automated-item-insertion')

data:extend{entity}

local item = {
  type = 'item',
  name = 'fulgoran-construction-hub',
  order = 'c[fulgoran-construction-hub]',
  subgroup = 'environmental-protection',
  stack_size = 1,
  weight = 1000000,
}

item.icon = entity.icon

item.place_result = 'fulgoran-construction-hub'
entity.minable.result = 'fulgoran-construction-hub'

data:extend{item}

-- cloned from "electromagnetic-science-pack"
local recipe = {
  type = "recipe",
  name = "fulgoran-construction-hub",
  category = "electromagnetics",
  surface_conditions =
  {
    {
      property = "magnetic-field",
      min = 99,
      max = 99
    }
  },
  enabled = false,
  ingredients =
  {
    --
  },
  energy_required = 10,
  results = {{type="item", name=item.name, amount=1}},
  allow_productivity = false,
  requester_paste_multiplier = 1
}

local ingredients = {}
for _, result in ipairs(data.raw["recipe"]["scrap-recycling"].results) do
  table.insert(recipe.ingredients, {type = "item", name = result.name, amount = result.probability * 100})
end

data:extend{recipe}

local effects = data.raw["technology"]["electromagnetic-plant"].effects
for i, effect in ipairs(effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "electromagnetic-plant" then
    table.insert(effects, i + 1, {type = "unlock-recipe", recipe = recipe.name})
    break
  end
end
