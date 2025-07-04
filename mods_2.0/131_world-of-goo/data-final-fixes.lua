local planet = data.raw["planet"]["world-of-goo"]
local distance = planet.distance * 32 * 8
local orientation = planet.orientation

local function get_position()
  return {distance * math.sin(orientation * 2 * math.pi), -distance * math.cos(orientation * 2 * math.pi)}
end

data:extend{{
  type = "space-location",
  name = "world-of-goo-base",
  icon = "__core__/graphics/empty.png",
  icon_size = 1,

  starmap_icon = "blep",
  starmap_icons = {
    {icon = "__core__/graphics/empty.png", icon_size = 1},
    {icon = mod_directory .. "/graphics/balls/common/body.png", shift = get_position(), floating = true},
  },

  distance = 0,
  orientation = 0.5,
}}
