require("shared")

data:extend{{
  type = "planet",
  name = mod_name,
  icon = "__Krastorio2Assets__" .. "/icons/entities/air-purifier.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

assert(data.raw["furnace"]["kr-air-purifier"], "no mod has defined the kr-air-purifier furnace.")
assert(data.raw["item"]["pollution-filter"] or data.raw["item"]["kr-pollution-filter"], "no mod has defined the kr-pollution-filter item.")

-- data.raw["furnace"]["kr-air-purifier"].crafting_speed = 100
data.raw["furnace"]["kr-air-purifier"].icons_positioning =
{
  {inventory_index = defines.inventory.crafter_input, scale = 0.75, shift = {0, -1.5}},
}
