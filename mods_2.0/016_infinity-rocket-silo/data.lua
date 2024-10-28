local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
local silo_item = table.deepcopy(data.raw["item"]["rocket-silo"])


silo.name = "infinity-rocket-silo"
silo.heating_energy = nil -- frozen sprites missing (gimp, hue saturation, -60)

silo.base_day_sprite.filename = "__infinity-rocket-silo__/graphics/entity/infinity-rocket-silo/06-infinity-rocket-silo.png"
silo.base_front_sprite.filename = "__infinity-rocket-silo__/graphics/entity/infinity-rocket-silo/14-infinity-rocket-silo-front.png"

silo_item.name = silo.name
silo_item.icon = "__infinity-rocket-silo__/graphics/icons/infinity-rocket-silo.png"

silo_item.place_result = silo.name
silo.minable.result = silo_item.name

data:extend{silo, silo_item}
