local equipment_train_stop = flib.copy_prototype(data.raw["recipe"]["train-stop"], mod_prefix .. "station")
equipment_train_stop.ingredients = {
  {type = "item", name = "train-stop",  amount = 1},
  {type = "item", name = "steel-chest", amount = 1},
}

data:extend({equipment_train_stop})
