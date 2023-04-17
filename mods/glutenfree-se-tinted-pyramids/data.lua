local tints = {
  ['white'] = {r=1.0, g=1.0, b=1.0, a=1},
  ['red']   = {r=1.0, g=0.7, b=0.7, a=1},
  ['green'] = {r=0.7, g=1.0, b=0.7, a=1},
  ['blue']  = {r=0.7, g=0.7, b=1.0, a=1},
}
local pyramid_types = {'a', 'b', 'c'}

for _, pyramid_type in ipairs(pyramid_types) do
  for color, tint in pairs(tints) do

    local pyramid = table.deepcopy(data.raw['simple-entity']['se-pyramid-' .. pyramid_type])
    pyramid.name = pyramid.name .. '-tinted-' .. color
    pyramid.picture.layers[1].tint = tint
    pyramid.collision_mask = {}
    -- pyramid.allow_in_space = true

    pyramid.icons = {{
      icon = pyramid.icon,
      tint = tint,
    }}

    -- print(serpent.block(pyramid))

    data:extend({pyramid})

  end

  -- turn the real pyramid (almost) invisible while this mod is installed so SE doesn't freak out, reversible :)
  data.raw['simple-entity']['se-pyramid-' .. pyramid_type].picture.layers[1].tint = {r=0.1, g=0.1, b=0.1, a=0.2}
  data.raw['simple-entity']['se-pyramid-' .. pyramid_type].picture.layers[2].tint = {r=0.1, g=0.1, b=0.1, a=0.2}
end
