local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

data:extend{{
  type = "planet",
  name = "world-of-goo",
  order = "a[world-of-goo]",
  -- icon = mod_directory .. "/graphics/common-body.png",
  icons = {
    {icon = mod_directory .. "/graphics/common-body.png", size = 64, scale = 1},

    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_2.png", icon_size = 23, shift = {-0.50 * 32, -0.10 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = {-0.45 * 32, -0.15 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_1.png", icon_size = 32, shift = { 0.30 * 32, -0.30 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = { 0.35 * 32, -0.35 * 32}, scale = 1, floating = true},
  },

  distance = 15,
  orientation = 0.32,

  starmap_icon = "blep",
  starmap_icons = {
    {icon = mod_directory .. "/graphics/common-body.png", size = 64, scale = 1},

    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_2.png", icon_size = 23, shift = {-0.50 * 32, -0.10 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = {-0.45 * 32, -0.15 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/eye_glass_1.png", icon_size = 32, shift = { 0.30 * 32, -0.30 * 32}, scale = 1, floating = true},
    {icon = mod_directory .. "/graphics/balls/_generic/pupil1.png"     , icon_size =  8, shift = { 0.35 * 32, -0.35 * 32}, scale = 1, floating = true},

    {icon = mod_directory .. "/graphics/telescope-19x19.png", icon_size = 19, shift = { 0.7 * 32, -1.2 * 32}, scale = 1.5, floating = true},
  },

  subgroup = data.raw["planet"]["nauvis"].subgroup,
  asteroid_spawn_influence = data.raw["planet"]["nauvis"].asteroid_spawn_influence,
  asteroid_spawn_definitions = data.raw["planet"]["nauvis"].asteroid_spawn_definitions,
}}

data:extend{
  {
    type = "space-connection",
    name = "nauvis-world-of-goo",
    subgroup = "planet-connections",
    from = "nauvis",
    to = "world-of-goo",
    order = "1",
    length = 5000,
  },
}

do
  local prototype = data.raw["space-connection"]["nauvis-world-of-goo"]
  local from = data.raw["planet"]["nauvis"]
  local to = data.raw["planet"]["world-of-goo"]
  prototype.icons =
  {
    {icon = "__space-age__/graphics/icons/planet-route.png"},
    {icon = from.icon, icon_size = from.icon_size or 64, scale = 0.333 * (64 / (from.icon_size or 64)), shift = {-6, -6}},
  }

  for _, icondata in ipairs(to.icons) do
    local _icondata = table.deepcopy(icondata)
    _icondata.scale = (_icondata.scale or 1) * 0.333
    _icondata.shift = _icondata.shift or {0, 0}
    _icondata.shift[1] = (_icondata.shift[1] * 0.333) + 6
    _icondata.shift[2] = (_icondata.shift[2] * 0.333) + 6
    table.insert(prototype.icons, _icondata)
  end
end

table.insert(data.raw["technology"]["oil-processing"].effects, {
  type = "unlock-space-location",
  space_location = "world-of-goo",
  use_icon_overlay_constant = true
})
