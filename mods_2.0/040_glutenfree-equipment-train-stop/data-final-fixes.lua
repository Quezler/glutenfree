local mod_item = data.raw["item"]["glutenfree-equipment-train-stop-station"]
local train_stop = data.raw["item"]["train-stop"]

mod_item.order = train_stop.order .. "-d"
mod_item.subgroup = train_stop.subgroup

local steel_chest = data.raw["item"]["steel-chest"]
if steel_chest.icons then
  steel_chest = steel_chest.icons[1]
end

mod_item.icons = {
  {icon = train_stop.icon},
  {icon = steel_chest.icon, scale = 0.25, shift = {8, 8}},
}

data.raw["train-stop"]["glutenfree-equipment-train-stop-station"].icons = mod_item.icons
data.raw["land-mine"]["glutenfree-equipment-train-stop-tripwire"].collision_mask = {layers = {train = true}}
