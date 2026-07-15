local subgroup = "production-machine"

if mods["space-exploration"] then
  subgroup = "radiation"
end

local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
  {
    type = "item",
    name = "k11-advanced-centrifuge",
    icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon.png",
    subgroup = subgroup,
    order = "g[centrifuge]-a[advanced-centrifuge]", -- Needs adjustment
    inventory_move_sound = item_sounds.mechanical_inventory_move,
    pick_sound = item_sounds.mechanical_inventory_pickup,
    drop_sound = item_sounds.mechanical_inventory_move,
    place_result = "k11-advanced-centrifuge",
    stack_size = 10,
  }
})
