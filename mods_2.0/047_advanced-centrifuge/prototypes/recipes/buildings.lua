local ingredients = {
  {"centrifuge", 8},
  {"processing-unit", 50},
  {"electric-engine-unit", 40},
  {"concrete", 200},
}

-- Changes for K2

if mods["Krastorio2"] then
  table.insert(ingredients, {"energy-control-unit", 20})
end

-- Changes for SE

if mods["space-exploration"] then
  table.insert(ingredients, {"se-heavy-bearing", 20})
  table.insert(ingredients, {"se-heavy-girder", 40})
end

data:extend({
  {
    type = "recipe",
    name = "k11-advanced-centrifuge",
    energy_required = 30,
    enabled = false,
    ingredients = ingredients,
    result = "k11-advanced-centrifuge",
  }
})  