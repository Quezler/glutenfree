local ingredients = {
  {type = "item", name = "centrifuge", amount = 8},
  {type = "item", name = "processing-unit", amount = 50},
  {type = "item", name = "electric-engine-unit", amount = 40},
  {type = "item", name = "concrete", amount = 200},
}

-- Changes for K2

if mods["Krastorio2"] then
  table.insert(ingredients, {type = "item", name = "energy-control-unit", amount = 20})
end

-- Changes for SE

if mods["space-exploration"] then
  table.insert(ingredients, {type = "item", name = "se-heavy-bearing", amount = 20})
  table.insert(ingredients, {type = "item", name = "se-heavy-girder", amount = 40})
end

data:extend({
  {
    type = "recipe",
    name = "k11-advanced-centrifuge",
    energy_required = 30,
    enabled = false,
    ingredients = ingredients,
    results = {{type = "item", name = "k11-advanced-centrifuge", amount = 1}},
  }
})
