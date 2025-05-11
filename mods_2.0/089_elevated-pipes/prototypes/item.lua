local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")

local item = {
  type = "item",
  name = "elevated-pipe",
  icon = mod_directory .. "/graphics/icons/elevated-pipe.png",
  subgroup = "energy-pipe-distribution",
  order = "a[pipe]-b[elevated-pipe]",
  inventory_move_sound = item_sounds.metal_small_inventory_move,
  pick_sound = item_sounds.metal_small_inventory_pickup,
  drop_sound = item_sounds.metal_small_inventory_move,
  place_result = "elevated-pipe",
  stack_size = 100 / 5,
  weight = 5 * kg * 5,
  random_tint_color = item_tints.iron_rust
}

data:extend{item}
