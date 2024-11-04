local combinator = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"])
local combinator_item = table.deepcopy(data.raw["item"]["decider-combinator"])

combinator.name = "alchemical-combinator"
combinator_item.name = combinator.name

combinator.minable.result = combinator_item.name
combinator_item.place_result = combinator.name

local combinator_active = table.deepcopy(combinator) -- mine result = alchemical combinator
combinator_active.name = "alchemical-combinator-active"

combinator.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"
combinator_item.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"
combinator_active.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator-active.png"

combinator.sprites.north.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.east .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.south.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.west .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"

combinator_active.sprites.north.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.east .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.south.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.west .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"

combinator_active.selection_priority = (combinator.selection_priority or 50) + 1

data:extend{combinator, combinator_item, combinator_active}

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
