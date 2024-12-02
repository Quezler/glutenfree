require("prototypes.undersea-data-cable")
require("prototypes.undersea-data-cable-interface")

data:extend{{
  type = "planet",
  name = "undersea-data-cable",
  icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

local technology_effects = data.raw["technology"]["circuit-network"].effects --[[@as table]]
table.insert(technology_effects, {type = "unlock-recipe", recipe = "undersea-data-cable"})
table.insert(technology_effects, {type = "unlock-recipe", recipe = "undersea-data-cable-interface"})
