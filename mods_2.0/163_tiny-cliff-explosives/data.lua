local tiny = "tiny-"
local count_multiplier = 5
local scale_multiplier = 0.5
local radius_multiplier = (1/3) * 0.2 -- 1.5 -> 0.1
local energy_multiplier = 0.5

local item = table.deepcopy(data.raw["capsule"]["cliff-explosives"])
item.name = tiny .. item.name
item.icon = "__tiny-cliff-explosives__/graphics/icons/tiny-cliff-explosives.png"
item.stack_size = item.stack_size * count_multiplier
-- item.capsule_action.attack_parameters.range = item.capsule_action.attack_parameters.range * count_multiplier
-- item.capsule_action.attack_parameters.cooldown = item.capsule_action.attack_parameters.cooldown / count_multiplier

local recipe = {
  type = "recipe",
  name = item.name,
  enabled = false,
  energy_required = data.raw["recipe"]["cliff-explosives"].energy_required * energy_multiplier,
  ingredients = {{type = "item", name = "cliff-explosives", amount = 1}},
  results = {{type = "item", name = item.name, amount = count_multiplier}}
}

local projectile = table.deepcopy(data.raw["projectile"]["cliff-explosives"])
projectile.name = tiny .. projectile.name
projectile.shadow.scale = projectile.shadow.scale * scale_multiplier
projectile.animation.scale = projectile.animation.scale * scale_multiplier

for _, target_effect in ipairs(projectile.action[1].action_delivery.target_effects) do
  if target_effect.radius then
    target_effect.radius = target_effect.radius * radius_multiplier
  end
end
item.capsule_action.radius = item.capsule_action.radius * radius_multiplier
item.capsule_action.attack_parameters.ammo_type.action.action_delivery.projectile = projectile.name
item.capsule_action.attack_parameters.ammo_type.action.action_delivery.starting_speed = 0.1 -- was 0.3

local effects = data.raw["technology"]["cliff-explosives"].effects or {}
for i, effect in ipairs(effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "cliff-explosives" then
    table.insert(effects, i + 1, {type = "unlock-recipe", recipe = recipe.name})
  end
end

for _, cliff in pairs(data.raw.cliff) do
  cliff.cliff_explosive = item.name
end

data:extend{item, recipe, projectile}
