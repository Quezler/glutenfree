require('constants')

data:extend({
  {
    name = tile_name,
    type = "tile",
    order = "z[other]-a[".. tile_name .. "]",
    collision_mask =
    {
      -- "ground-tile",
      -- "water-tile",
      -- "resource-layer",
      -- "floor-layer",
      -- "item-layer",
      -- "object-layer",
      -- "player-layer",
      -- "doodad-layer"
    },
    layer_group = "zero",
    layer = 0,
    variants =
    {
      main =
      {
        {
          picture = "__base__/graphics/terrain/out-of-map.png",
          count = 1,
          size = 1
        }
      },
      empty_transitions = true
    },
    map_color = {r=0, g=0, b=0},
    pollution_absorption_per_second = 10,
    minable = {
      mining_time = 1,
    },
  },
})

-- print(serpent.block( data.raw['tile']['water'].transitions ))

local function table_contains(t, v)
  for _, value in ipairs(t) do
    if value == v then return true end
  end

  return false
end

for _, tile in pairs(data.raw['tile']) do
  for _, transition in ipairs(tile.transitions or {}) do
    print(serpent.block(transition.to_tiles))
    if table_contains(transition.to_tiles, "out-of-map") and not table_contains(transition.to_tiles, tile_name) then
      table.insert(transition.to_tiles, tile_name)
    end
  end
end

-- print(serpent.block( data.raw['tile']['water'].transitions ))
