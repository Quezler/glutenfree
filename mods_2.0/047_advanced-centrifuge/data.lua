require("prototypes/entities/buildings/advanced-centrifuge")
require("prototypes/items/buildings")
require("prototypes/recipes/buildings")
require("prototypes/technologies/buildings")

if mods["space-exploration"] then
  data.raw["item"              ]["k11-advanced-centrifuge"].icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-base.png"
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-base.png"
end
