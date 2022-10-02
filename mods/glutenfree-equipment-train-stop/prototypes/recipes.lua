local equipment_train_stop = flib.copy_prototype(data.raw['recipe']['train-stop'], mod_prefix .. 'station')
equipment_train_stop.ingredients = {
  {'train-stop', 1},
  {'steel-chest', 1},
}
equipment_train_stop.enabled = true

data:extend({equipment_train_stop})
