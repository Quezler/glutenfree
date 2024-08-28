data:extend{
  {
    type = 'resource-category',
    name = 'se-core-mining-omni',
  }
}

-- data.raw['resource']['se-core-fragment-omni'].collision_box = {{-1, -1}, {1, 1}}
-- data.raw['resource']['se-core-fragment-omni'].selection_box = {{-1, -1}, {1, 1}}
-- -- data.raw['resource']['se-core-fragment-omni'].selectable_in_game = false
-- data.raw['resource']['se-core-fragment-omni'].category = 'se-core-mining-omni'
-- data.raw['resource']['se-core-fragment-omni'].stages.sheet.tint = {0,0,0,0}
-- data.raw['resource']['se-core-fragment-omni'].stages_effect.sheet.tint = {0,0,0,0}
-- -- data.raw['resource']['se-core-fragment-omni-sealed']

-- this hides the seam from the players, effectively its still very much there,
-- the only thing we "damage beyond repair" is the smoke effect and the map tag.

-- data.raw['resource']['se-core-fragment-omni-sealed'].selectable_in_game = false
data.raw['resource']['se-core-fragment-omni-sealed'].category = 'se-core-mining-omni'
data.raw['resource']['se-core-fragment-omni-sealed'].stages.sheet.tint = {0,0,0,0}
data.raw['resource']['se-core-fragment-omni-sealed'].stages_effect.sheet.tint = {0,0,0,0}
table.insert(data.raw['resource']['se-core-fragment-omni-sealed'].flags, 'not-on-map')
