require("shared")

-- local Hurricane = require("graphics/hurricane")
-- local skin = Hurricane.crafter({
--   directory = mod_directory .. "factorio-sprites",
--   name = "radio-station",
--   width = 1280, height = 870,
--   total_frames = 20, rows = 3, -- custom
--   shadow_width = 400, shadow_height = 350,
--   shift = {0, 0.25}, -- custom
-- })

local crafting_category = {
  type = "recipe-category",
  name = mod_name,
}

local Hurricane = require("hurricane")
local skin = Hurricane.assembling_machine(mod_directory .. "/factorio-sprites", "radio-station")

local entity = {
  type = "assembling-machine",
  name = skin.name,
  localised_name = skin.name,
  icon = skin.icon,

  selection_box = {{-3.0, -3.0}, {3.0, 3.0}},
  collision_box = {{-2.8, -2.8}, {2.8, 2.8}},

  crafting_categories = {crafting_category.name},
  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  energy_usage = "1GW",
  energy_source = {type = "void"},
  minable = {mining_time = 1},

  flags = {"player-creation"},
}

data:extend{crafting_category, entity}
