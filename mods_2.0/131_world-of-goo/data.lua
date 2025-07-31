require("namespace")

require("prototypes.planet")
require("prototypes.tiles")
require("prototypes.entities")
require("prototypes.ball-sprites")

local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

local fish = {
  type = "fish",
  name = "goo-ball",
  icon = mod_directory .. "/graphics/balls/common-body.png",
  flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
  minable = {mining_time = 0.25, result = "goo-ball", count = 1},
  mined_sound = sounds.mine_fish,
  max_health = 25,
  subgroup = "creatures",
  order = "b-b",
  -- factoriopedia_simulation = simulations.factoriopedia_fish,
  collision_box = {{-1.0, -1.0}, {1.0, 1.0}},
  selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  pictures =
  {
    {
      filename = mod_directory .. "/graphics/balls/common-body.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      scale = 0.2, -- 0.5 smaller so its behind the lua rendering
      tint = {0, 0, 0, 0} -- todo: deepcopy for drool ball
    }
  },
  autoplace = { probability_expression = 0.01 },
  protected_from_tile_building = false,

  created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "script",
          effect_id = "goo-ball-created",
        },
      }
    }
  },
}

local item = {
  type = "item",
  name = "goo-ball",
  icon = mod_directory .. "/graphics/balls/common-body.png",
  subgroup = "raw-resource",
  order = "i[goo-ball]",
  inventory_move_sound = item_sounds.raw_fish_inventory_move,
  pick_sound = item_sounds.raw_fish_inventory_pickup,
  drop_sound = item_sounds.raw_fish_inventory_move,
  stack_size = 10,
}

data:extend{fish, item}
