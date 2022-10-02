local equipment_train_stop = flib.copy_prototype(data.raw['item']['train-stop'], mod_prefix .. 'station')
equipment_train_stop.icon = '__glutenfree-equipment-train-stop__/graphics/icons/equipment-train-stop.png'
equipment_train_stop.icon_size = 64
equipment_train_stop.icon_mipmaps = 4

data:extend({equipment_train_stop})
