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

local order = string.format("hurricane[%s]", skin.name)

local entity = {
  type = "assembling-machine",
  name = skin.name,
  localised_name = skin.name,

  icon = skin.icon,
  order = order,

  selection_box = skin.selection_box,
  collision_box = skin.collision_box,

  crafting_categories = {crafting_category.name},
  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  energy_usage = "1GW",
  energy_source = {type = "void"},
  minable = {mining_time = 0.2},

  flags = {"player-creation"},
}

local item = {
  type = "item",
  name = skin.name,

  icon = skin.icon,
  order = order,

  stack_size = 10,
  weight = 100*kg,
  place_result = entity.name,
}
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = item.name,

  icon = item.icon,
  energy_required = 0.1,

  ingredients = {},
  results = {
    {type = "item", name = item.name, amount = 1},
  },
}

data:extend{crafting_category, entity, item, recipe}
