require("namespace")

require("prototypes.planet")

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
  filename = mod_directory .. "/graphics/balls/common/body.png",
  width = 64,
  height = 64,
  scale = 0.25,
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

data.raw["tile"]["water"].variants.main[1].picture = mod_directory .. "/graphics/terrain/water/crude-oil1.png"
data.raw["tile"]["water"].variants.main[2].picture = mod_directory .. "/graphics/terrain/water/crude-oil2.png"
data.raw["tile"]["water"].variants.main[3].picture = mod_directory .. "/graphics/terrain/water/crude-oil4.png"
data.raw["tile"]["water"].effect_color = {0.2, 0.2, 0.2, 1}
data.raw["tile"]["water"].effect_color_secondary = {0.2, 0.2, 0.2, 1}
data.raw["tile"]["water"].map_color = {0.2, 0.2, 0.2, 1}

data.raw["tile"]["deepwater"].variants.main[1].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil1.png"
data.raw["tile"]["deepwater"].variants.main[2].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil2.png"
data.raw["tile"]["deepwater"].variants.main[3].picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil4.png"
data.raw["tile"]["deepwater"].effect_color = {0.1, 0.1, 0.1, 1}
data.raw["tile"]["deepwater"].effect_color_secondary = {0.1, 0.1, 0.1, 1}
data.raw["tile"]["deepwater"].map_color = {0.1, 0.1, 0.1, 1}

local fish = {
  type = "fish",
  name = "goo-ball",
  icon = mod_directory .. "/graphics/balls/common/body.png",
  flags = {"placeable-neutral", "not-on-map"},
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
      filename = mod_directory .. "/graphics/balls/common/body.png",
      priority = "extra-high",
      width = 64,
      height = 64,
      scale = 0.2, -- 0.5 smaller so its behind the lua rendering
    }
  },
  autoplace = { probability_expression = 0.1 },
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
  icon = mod_directory .. "/graphics/balls/common/body.png",
  subgroup = "raw-resource",
  order = "i[goo-ball]",
  inventory_move_sound = item_sounds.raw_fish_inventory_move,
  pick_sound = item_sounds.raw_fish_inventory_pickup,
  drop_sound = item_sounds.raw_fish_inventory_move,
  stack_size = 10,
}

data:extend{fish, item}

data.raw["planet"]["nauvis"].map_gen_settings.autoplace_settings.entity.settings["goo-ball"] = {}
data.raw["planet"]["nauvis"].map_gen_settings.autoplace_settings.entity.settings["fish"] = nil
