-- data.raw['land-mine']['land-mine'].collision_mask = {'train-layer'}

local landmine = table.deepcopy(data.raw['land-mine']['land-mine'])
landmine.name = 'glutenfree-equipment-train-stop-tripwire'
landmine.collision_mask = {'train-layer'}
landmine.max_health = 1
landmine.timeout = 4294967295 -- 2^32-1

data:extend({landmine})
