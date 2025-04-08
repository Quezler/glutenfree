local uranium_238 = data.raw["item"]["uranium-238"] -- dark green
local uranium_235 = data.raw["item"]["uranium-235"] -- bright green

uranium_238.place_as_tile =
{
  result = "green-refined-concrete",
  condition_size = 1,
  condition = {layers = {}},
  tile_condition = {"refined-concrete", "frozen-refined-concrete"}
}

uranium_235.place_as_tile =
{
  result = "acid-refined-concrete",
  condition_size = 1,
  condition = {layers = {}},
  tile_condition = {"refined-concrete", "frozen-refined-concrete"}
}
