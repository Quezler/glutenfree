local pump      = table.deepcopy(data.raw["pump"]["pump"])
local pump_item = table.deepcopy(data.raw["item"]["pump"])

pump.name = "pump-with-adjustable-flow-rate"
pump_item.name = pump.name

pump.minable.result = pump_item.name
pump_item.place_result = pump.name

local pump_recipe = {
  type = "recipe",
  name = pump_item.name,
  energy_required = 2,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "pump", amount = 1},
    {type = "item", name = "arithmetic-combinator", amount = 1},
  },
  results = {{type="item", name=pump_item.name, amount=1}}
}

local technology = data.raw["technology"]["fluid-handling"]
for i, effect in ipairs(technology.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "pump" then
    table.insert(technology.effects, i + 1, {
      type = "unlock-recipe",
      recipe = pump_recipe.name,
    })
    break
  end
end

data:extend{pump, pump_item, pump_recipe, pump_recipe}
