local tile_proxy = data.raw['deconstructible-tile-proxy']['deconstructible-tile-proxy']

tile_proxy.collision_mask = tile_proxy.collision_mask or {'ground-tile'}
table.insert(tile_proxy.collision_mask, collision_mask_util_extended.get_named_collision_mask('space-tile'))
