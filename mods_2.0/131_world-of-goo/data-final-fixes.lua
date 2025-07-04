local utility_sprites = data.raw["utility-sprites"]["default"]
local starmap_star = utility_sprites.starmap_star

if not starmap_star.layers then
  starmap_star = {layers = {starmap_star}}
  utility_sprites.starmap_star = starmap_star
end

local planet = data.raw["planet"]["world-of-goo"]
local distance = planet.distance * 32
local orientation = planet.orientation

local function get_position()
  return {distance * math.sin(orientation * 2 * math.pi), -distance * math.cos(orientation * 2 * math.pi)}
end

table.insert(starmap_star.layers, {
  filename = mod_directory .. "/graphics/balls/common/body.png",
  priority = "extra-high-no-scale",
  size = 64,
  flags = {"gui-icon"},
  scale = 0.5,
  shift = get_position(),
})
