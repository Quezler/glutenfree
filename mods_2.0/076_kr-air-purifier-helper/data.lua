require("shared")

data:extend{{
  type = "planet",
  name = mod_name,
  icon = "__Krastorio2Assets__" .. "/icons/entities/air-purifier.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

assert(data.raw["furnace"]["kr-air-purifier"], "no mod has defined an kr-air-purifier furnace.")
assert(data.raw["item"]["pollution-filter"], "no mod has defined an pollution-filter item.")

-- data.raw["furnace"]["kr-air-purifier"].crafting_speed = 100
data.raw["furnace"]["kr-air-purifier"].icons_positioning =
{
  {inventory_index = defines.inventory.furnace_source, scale = 0.75, shift = {0, -1.5}},
}
