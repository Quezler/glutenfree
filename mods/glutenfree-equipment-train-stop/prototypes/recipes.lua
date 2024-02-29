local equipment_train_stop = flib.copy_prototype(data.raw['recipe']['train-stop'], mod_prefix .. 'station')
equipment_train_stop.ingredients = {
  {'train-stop', 1},
  {'steel-chest', 1},
}
-- equipment_train_stop.enabled = true

table.insert(data.raw['technology']['automated-rail-transportation'].effects, {
  type = 'unlock-recipe',
  recipe = 'glutenfree-equipment-train-stop-station',
})

data:extend({equipment_train_stop})
