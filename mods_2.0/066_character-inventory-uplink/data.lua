require("shared")

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "suit-plug-outlet",
  width = 1280, height = 580,
  total_frames = 16, rows = 2, -- notice: rows
  shadow_width = 400, shadow_height = 350,
})

local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
entity.name = mod_name
entity.icon = skin.icon
entity.graphics_set = skin.graphics_set
entity.crafting_speed = 1
entity.selection_box[2][2] = entity.selection_box[2][2] + 1
entity.collision_box[2][2] = entity.collision_box[2][2] + 1
entity.next_upgrade = nil
data:extend{entity}

data.raw["item"]["assembling-machine-1"].place_result = entity.name
