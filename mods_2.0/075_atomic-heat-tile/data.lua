require("shared")

local green_tile = table.deepcopy(data.raw["tile"]["green-refined-concrete"])
local acid_tile  = table.deepcopy(data.raw["tile"][ "acid-refined-concrete"])

green_tile.name = mod_prefix .. green_tile.name
 acid_tile.name = mod_prefix ..  acid_tile.name

green_tile.minable = {mining_time = 0.5}
 acid_tile.minable = {mining_time = 0.5}

-- green_tile.minable.results = {{type = "item", name = "uranium-238", amount = 1}, {type = "item", name = "refined-concrete", amount = 1}}
--  acid_tile.minable.results = {{type = "item", name = "uranium-235", amount = 1}, {type = "item", name = "refined-concrete", amount = 1}}

data:extend{green_tile, acid_tile}

local uranium_green = data.raw["item"]["uranium-238"]
local uranium_acid  = data.raw["item"]["uranium-235"]

uranium_green.place_as_tile =
{
  result = green_tile.name,
  condition_size = 1,
  condition = {layers={water_tile=true}},
  -- tile_condition = {"refined-concrete", "frozen-refined-concrete"}
}

uranium_acid.place_as_tile =
{
  result = acid_tile.name,
  condition_size = 1,
  condition = {layers={water_tile=true}},
  -- tile_condition = {"refined-concrete", "frozen-refined-concrete"}
}

-- data.raw["tile"][       "concrete"].default_cover_tile =        "refined-concrete"
-- data.raw["tile"]["frozen-concrete"].default_cover_tile = "frozen-refined-concrete"

for _, tile_name in ipairs(data.raw["item"]["ice-platform"].place_as_tile.tile_condition) do
  table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, tile_name)
end
