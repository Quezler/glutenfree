require("shared")

local entity = table.deepcopy(data.raw["space-platform-hub"]["space-platform-hub"])
entity.name = "creative-" .. entity.name

local item = table.deepcopy(data.raw["space-platform-starter-pack"]["space-platform-starter-pack"])
item.name = "creative-" .. item.name
item.order = "c[creative-space-platform-starter-pack]"
item.trigger[1].action_delivery.source_effects[1].entity_name = entity.name

data:extend{entity, item}
