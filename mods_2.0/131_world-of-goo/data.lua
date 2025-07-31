require("namespace")

require("prototypes.planet")
require("prototypes.tiles")
require("prototypes.entities")

local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

data:extend{{
  type = "sprite",
  name = "goo-ball",
  filename = mod_directory .. "/graphics/goo-ball-3.png",
  width = 171,
  height = 171,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "common-body",
  layers = {
    {
      filename = mod_directory .. "/graphics/balls/_generic/shadowCircle59.png",
      priority = "extra-high",
      width = 59,
      height = 59,
      scale = 0.4,
    },
    {
      filename = mod_directory .. "/graphics/common-body.png",
      width = 64,
      height = 64,
      scale = 0.25,
    },
  }
}}

data:extend{{
  type = "sprite",
  name = "drool-body",
  layers = {
    {
      filename = mod_directory .. "/graphics/balls/water/shad.png",
      priority = "extra-high",
      width = 59,
      height = 59,
      scale = 0.4,
    },
    {
      filename = mod_directory .. "/graphics/balls/water/body.png",
      width = 64,
      height = 64,
      scale = 0.25,
    },
  }
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-1",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_1.png",
  width = 32,
  height = 32,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-2",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_2.png",
  width = 23,
  height = 23,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-glass-3",
  filename = mod_directory .. "/graphics/balls/_generic/eye_glass_3.png",
  width = 16,
  height = 16,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-pupil",
  filename = mod_directory .. "/graphics/balls/_generic/pupil1.png",
  width = 8,
  height = 8,
  scale = 0.25,
}}

local fish = {
  type = "fish",
  name = "goo-ball",
  icon = mod_directory .. "/graphics/common-body.png",
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
      filename = mod_directory .. "/graphics/common-body.png",
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
  icon = mod_directory .. "/graphics/common-body.png",
  subgroup = "raw-resource",
  order = "i[goo-ball]",
  inventory_move_sound = item_sounds.raw_fish_inventory_move,
  pick_sound = item_sounds.raw_fish_inventory_pickup,
  drop_sound = item_sounds.raw_fish_inventory_move,
  stack_size = 10,
}

data:extend{fish, item}
