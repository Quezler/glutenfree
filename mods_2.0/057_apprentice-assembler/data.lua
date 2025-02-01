require("shared")
local Hurricane = require("graphics.hurricane")

local a_5x5_entity = data.raw["reactor"]["nuclear-reactor"]

local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
entity.name = mod_name

entity.collision_box = table.deepcopy(a_5x5_entity.collision_box)
entity.selection_box = table.deepcopy(a_5x5_entity.selection_box)

local gravity_assembler = Hurricane.crafter({
  name = "gravity-assembler",
  width = 2560, height = 2560, -- of one of the sheets
  rows = 8, columns = 8,
  total_frames = (8 * 8) + (8 * 4 + 4),
  shadow_width = 520, shadow_height = 500,
})

entity.icon = gravity_assembler.icon
entity.graphics_set = gravity_assembler.graphics_set

entity.icon_draw_specification = {shift = {0, -0.375}, scale = 1.5},

data:extend{entity}
