local mod_prefix = "circuit-controlled-beacon-interface--"

local entity = table.deepcopy(data.raw["beacon"]["beacon-interface--beacon"])
entity.name = mod_prefix .. "beacon"

local item = table.deepcopy(data.raw["item"]["beacon-interface--beacon"])
item.name = mod_prefix .. "beacon"

entity.minable.result = item.name
item.place_result = entity.name

entity.icons[2].icon = "__base__/graphics/icons/constant-combinator.png"
item.icons[2].icon = "__base__/graphics/icons/constant-combinator.png"

entity.graphics_set.animation_list[1].animation.layers[1].filename = "__circuit-controlled-beacon-interface__/graphics/entity/circuit-controlled-beacon-interface/circuit-controlled-beacon-interface-bottom.png"

data:extend{entity, item}
