-- log(serpent.block(data.raw['tile']['se-space'].collision_mask))

-- data.raw['tile']['se-space'].collision_mask['ground-tile'] = true
-- table.insert(data.raw['tile']['se-space'].collision_mask, 'ground-tile')
-- log(serpent.block(data.raw['tile']['se-space'].collision_mask))
-- data.raw['tile']['se-space-platform-plating'].collision_mask['ground-tile'] = true
-- table.insert(data.raw['tile']['se-space-platform-plating'].collision_mask, 'ground-tile')

data.raw['deconstructible-tile-proxy']['deconstructible-tile-proxy'].collision_mask = {'ground-tile', 'layer-18'}
