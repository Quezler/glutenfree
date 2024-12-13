local ingredients = {
		{ "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
		{ "production-science-pack", 1 },
		{ "utility-science-pack", 1 }
      }
	  
local prerequisites = {"uranium-processing"} 	  

-- Changes for K2

if mods["Krastorio2"] then
  table.insert(ingredients, {"matter-tech-card", 1})
  table.insert(ingredients, {"advanced-tech-card", 1})

  table.insert(prerequisites, "kr-energy-control-unit")
  table.insert(prerequisites, "kr-advanced-tech-card")
end

-- Changes for SE

if mods["space-exploration"] then
	ingredients = {
		{ "automation-science-pack", 1 },
        { "logistic-science-pack", 1 },
        { "chemical-science-pack", 1 },
        { "utility-science-pack", 1 },
        { "se-energy-science-pack-1", 1 },
        { "se-material-science-pack-2", 1 }
    }
	prerequisites = {"uranium-processing", "se-heavy-bearing"}
	
	if mods["Krastorio2"] then
	table.insert(prerequisites, "kr-energy-control-unit")
	end
	
end

data:extend({
    {
    type = "technology",
    name = "k11-advanced-centrifuge",
    mod = "Advanced Centrifuge",
    icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-tech-icon.png",
    icon_size = 256,
    icon_mipmaps = 4,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "k11-advanced-centrifuge",
      }
    },
    prerequisites = prerequisites,
    unit = {
      count = 1000,
	  time = 30,
      ingredients = ingredients
    }
  }
})  
