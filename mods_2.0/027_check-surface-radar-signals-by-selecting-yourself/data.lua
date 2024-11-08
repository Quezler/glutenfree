local mod_prefix = "csrsbsy-"

local proxy = table.deepcopy(data.raw["item-request-proxy"]["item-request-proxy"])
proxy.name = mod_prefix .. proxy.name

local character = data.raw["character"]["character"]
proxy.selection_box = character.selection_box
proxy.collision_box = character.collision_box
proxy.selection_priority = (character.selection_priority or 50) - 1

data:extend{proxy}
