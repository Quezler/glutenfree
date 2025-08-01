local tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_graphics = require("__base__/prototypes/tile/tile-graphics")
local tile_pollution = require("__base__/prototypes/tile/tile-pollution-values")

data:extend{{
  type = "item-subgroup",
  name = mod_prefix .. "tiles",
  group = "tiles",
  order = "e"
}}

local shallow =
{
  type = "tile",
  name = mod_prefix .. "crude-oil-shallow",
  order = "a[water]-a[water]",
  collision_mask = tile_collision_masks.water(),
  subgroup = mod_prefix .. "tiles",
  fluid = "crude-oil",
  autoplace = data.raw["tile"]["oil-ocean-shallow"].autoplace,
  effect = "water",
  effect_color = {0.2, 0.2, 0.2, 1},
  effect_color_secondary = {0.2, 0.2, 0.2, 1},
  particle_tints = tile_graphics.water_particle_tints,
  layer_group = "water",
  layer = 3,
  variants =
  {
    main =
    {
      {
        picture = mod_directory .. "/graphics/terrain/water/crude-oil1.png",
        count = 1,
        scale = 0.5,
        size = 1
      },
      {
        picture = mod_directory .. "/graphics/terrain/water/crude-oil2.png",
        count = 1,
        scale = 0.5,
        size = 2
      },
      {
        picture = mod_directory .. "/graphics/terrain/water/crude-oil4.png",
        count = 1,
        scale = 0.5,
        size = 4
      }
    },
    empty_transitions = true
  },
  -- transitions = { water_to_out_of_map_transition },
  map_color = {0.2, 0.2, 0.2, 1},
  absorptions_per_second = tile_pollution.water,

  -- trigger_effect = tile_trigger_effects.water_trigger_effect(),

  default_cover_tile = "landfill",

  ambient_sounds = tile_sounds.ambient.water({volume = 0.6}),
}

local deep =
{
  type = "tile",
  name = mod_prefix .. "crude-oil-deep",
  order = "a[water]-b[deep-water]",
  subgroup = mod_prefix .. "tiles",
  transition_merges_with_tile = "water",
  collision_mask = tile_collision_masks.water(),
  fluid = "crude-oil",
  autoplace = data.raw["tile"]["oil-ocean-deep"].autoplace,
  effect = "water",
  effect_color = {0.1, 0.1, 0.1, 1},
  effect_color_secondary = {0.1, 0.1, 0.1, 1},
  particle_tints = tile_graphics.deepwater_particle_tints,
  layer_group = "water",
  layer = 3,
  variants =
  {
    main =
    {
      {
        picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil1.png",
        count = 1,
        scale = 0.5,
        size = 1
      },
      {
        picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil2.png",
        count = 1,
        scale = 0.5,
        size = 2
      },
      {
        picture = mod_directory .. "/graphics/terrain/deepwater/crude-oil4.png",
        count = 1,
        scale = 0.5,
        size = 4
      }
    },
    empty_transitions = true
  },
  --transitions = { deepwater_out_of_map_transition },
  --transitions_between_transitions = deepwater_transitions_between_transitions,
  -- allowed_neighbors = { "water" },
  map_color = {0.1, 0.1, 0.1, 1},
  absorptions_per_second = tile_pollution.water,

  -- trigger_effect = tile_trigger_effects.water_trigger_effect(),

  default_cover_tile = "landfill",

  ambient_sounds = tile_sounds.ambient.water({}),
}

data:extend{shallow, deep}

-- data.raw["tile"]["fulgoran-rock"].tint = {0.3, 0.3, 0.3, 1}
-- data.raw["tile"]["fulgoran-dust"].tint = {0.3, 0.3, 0.3, 1}
-- data.raw["tile"]["fulgoran-sand"].tint = {0.3, 0.3, 0.3, 1}
-- data.raw["tile"]["fulgoran-dunes"].tint = {0.3, 0.3, 0.3, 1}

local tiles_to_mimic = {
  ["fulgoran-rock" ] = {name = "goo-filled-rock" , map_color = {103, 140,  58}},
  ["fulgoran-dust" ] = {name = "goo-filled-dust" , map_color = { 89, 123,  41}},
  ["fulgoran-sand" ] = {name = "goo-filled-sand" , map_color = { 96, 122,  51}},
  ["fulgoran-dunes"] = {name = "goo-filled-dunes", map_color = {104, 131,  50}},
}

for from_name, to in pairs(tiles_to_mimic) do
  local tile = table.deepcopy(data.raw["tile"][from_name])
  tile.name = mod_prefix .. to.name
  tile.subgroup = mod_prefix .. "tiles"
  tile.variants.material_background.picture = mod_directory .. "/graphics/terrain/fulgoran/" .. to.name .. ".png"
  tile.map_color = to.map_color
  data:extend{tile}
end

-- purely to prevent the goo balls from clipping into the texture
-- not colliding based on entity since with that many fish the tile only check is cheaper
local pipe_cap_tile = table.deepcopy(data.raw["tile"]["deepwater"])
pipe_cap_tile.name = mod_prefix .. "pipe-cap-tile"
pipe_cap_tile.subgroup = mod_prefix .. "tiles"
pipe_cap_tile.collision_mask.layers.ground_tile = true
pipe_cap_tile.icon = mod_directory .. "/graphics/entity/pipe-cap.png"
pipe_cap_tile.icon_size = 100
pipe_cap_tile.hidden = true
data:extend{pipe_cap_tile}
