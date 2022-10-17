-- data.raw['simple-entity']['se-pyramid-a'].selectable_in_game = true
-- data.raw['simple-entity']['se-pyramid-b'].selectable_in_game = true
-- data.raw['simple-entity']['se-pyramid-c'].selectable_in_game = true

data.raw['simple-entity']['se-pyramid-a'].collision_mask = {}
data.raw['simple-entity']['se-pyramid-b'].collision_mask = {}
data.raw['simple-entity']['se-pyramid-c'].collision_mask = {}

data.raw['simple-entity']['se-pyramid-a'].allow_in_space = true
data.raw['simple-entity']['se-pyramid-b'].allow_in_space = true
data.raw['simple-entity']['se-pyramid-c'].allow_in_space = true

data.raw['simple-entity']['se-pyramid-a'].picture.layers[1].tint = {r=1, g=0.7, b=0.7, a=1}
data.raw['simple-entity']['se-pyramid-b'].picture.layers[1].tint = {r=0.7, g=1, b=0.7, a=1}
data.raw['simple-entity']['se-pyramid-c'].picture.layers[1].tint = {r=0.7, g=0.7, b=1, a=1}

local mod_prefix = 'glutenfree-se-pyramid-peeker-'

-- local itemframe = table.deepcopy(data.raw['container']['se-cartouche-chest'])

-- itemframe.name = mod_prefix .. 'container'
-- itemframe.flags = {
--   'not-on-map',
--   'not-blueprintable',
--   'not-deconstructable',
--   'hidden',
--   'no-automated-item-removal',
--   'no-automated-item-insertion',
--   'not-upgradable',
--   'not-in-kill-statistics',
--   'placeable-off-grid',
-- }
-- -- itemframe.selectable_in_game = false
-- itemframe.minable = nil
-- itemframe.collision_mask = {}
-- itemframe.selection_priority = 51

-- local container = table.deepcopy(data.raw['container']['logistic-robot-dropped-cargo'])
local container = table.deepcopy(data.raw['container']['se-cartouche-chest'])
container.name = mod_prefix .. 'container'
container.flags = {
  'not-on-map',
  'not-blueprintable',
  'not-deconstructable',
  'hidden',
  'no-automated-item-removal',
  'no-automated-item-insertion',
  'not-upgradable',
  'not-in-kill-statistics',
  'placeable-off-grid',
}
container.minable = nil
container.collision_mask = {}
container.allow_in_space = true
container.selectable_in_game = false
-- container.selection_box = {{-3,-3},{3,3}}

-- container.picture = data.raw['container']['se-cartouche-chest'].picture
-- container.selection_box = data.raw['container']['se-cartouche-chest'].selection_box

data:extend({container})
