require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "suit-plug-outlet",
  width = 1280, height = 580,
  total_frames = 16, rows = 2, -- custom
  shadow_width = 400, shadow_height = 350,
})

local entity = {
  type = "assembling-machine",
  name = mod_name,

  icon = skin.icon,
  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  selection_box = {{-1.5, -1.5}, {1.5, 2.5}},
  collision_box = {{-1.2, -1.2}, {1.2, 2.2}},

  energy_usage = "1kW",
  energy_source = {type = "void"},

  icon_draw_specification = {shift = {0, 0.75}, scale = 0.75},

  flags = {"player-creation", "placeable-player"},
  circuit_wire_max_distance = 9,
}

local item = {
  type = "item",
  name = mod_name,

  icon = skin.icon,

  stack_size = 5,
  weight = 200*kg,
  place_result = entity.name,
}

local recipe_category = {
  type = "recipe-category",
  name = mod_name,
}


local recipe = {
  type = "recipe",
  name = mod_prefix .. "active",

  icon = data.raw["character"]["character"].icon,

  energy_required = 1,

  ingredients = {},
  results = {},

  category = recipe_category.name,
}

entity.crafting_categories = {recipe_category.name}
entity.fixed_recipe = recipe.name
entity.fixed_quality = "normal"

data:extend{entity, item, recipe_category, recipe}
