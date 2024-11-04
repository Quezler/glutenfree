local combinator = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"])
local combinator_item = table.deepcopy(data.raw["item"]["decider-combinator"])

combinator.name = "alchemical-combinator"
combinator_item.name = combinator.name

combinator.minable.result = combinator_item.name
combinator_item.place_result = combinator.name

combinator.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"
combinator_item.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"

combinator.sprites.north.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.east .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.south.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.west .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"

data:extend{combinator, combinator_item}

local sound_charge = {
  type = "sound",
  name = "alchemical-combinator-charge",
  filename = "__alchemical-combinator__/sound/charge.ogg",
}

local sound_uncharge = {
  type = "sound",
  name = "alchemical-combinator-uncharge",
  filename = "__alchemical-combinator__/sound/uncharge.ogg",
}

data:extend{sound_charge, sound_uncharge}
