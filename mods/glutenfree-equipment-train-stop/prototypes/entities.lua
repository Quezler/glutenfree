local landmine = table.deepcopy(data.raw['land-mine']['land-mine'])
landmine.name = mod_prefix .. 'tripwire'
landmine.collision_mask = {'train-layer'}
landmine.max_health = 1
landmine.timeout = 4294967295 -- 2^32-1

data:extend({landmine})

local equipment_train_stop = flib.copy_prototype(data.raw['train-stop']['train-stop'], mod_prefix .. 'station')
equipment_train_stop.icon = '__glutenfree-equipment-train-stop__/graphics/icons/equipment-train-stop.png'
equipment_train_stop.icon_size = 64
equipment_train_stop.icon_mipmaps = 4
equipment_train_stop.next_upgrade = nil
equipment_train_stop.selection_box = {{-0.6, -0.6}, {0.6, 0.6}}

data:extend({equipment_train_stop})

local template_container = flib.copy_prototype(data.raw['container']['steel-chest'], mod_prefix .. 'template-container')
template_container.minable = nil
template_container.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
template_container.selection_priority = (template_container.selection_priority or 50) + 1
template_container.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
template_container.collision_mask = {"rail-layer"}

data:extend({template_container})
