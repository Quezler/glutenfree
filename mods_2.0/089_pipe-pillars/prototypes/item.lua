local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")

local item = {
  type = "item",
  name = "pipe-pillar",
  icon = mod_directory .. "/graphics/icons/pipe-pillar.png",
  subgroup = "energy-pipe-distribution",
  order = "a[pipe]-b[pipe-pillar]",
  inventory_move_sound = item_sounds.metal_small_inventory_move,
  pick_sound = item_sounds.metal_small_inventory_pickup,
  drop_sound = item_sounds.metal_small_inventory_move,
  place_result = "pipe-pillar",
  stack_size = 100 / 5,
  weight = 5 * kg * 5,
  random_tint_color = item_tints.iron_rust
}

data:extend{item}
