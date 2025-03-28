require("util")
require("shared")

local simple_entity = {
  type = "simple-entity",
  name = mod_prefix .. "simple-entity",

  icons = {
    {icon = data.raw["item"]["space-platform-foundation"].icon, tint = {0.5, 0.5, 1}},
  },

  selection_box = {{0, 0}, {0, 0}},
  collision_box = {{0, 0}, {0, 0}},

  collision_mask = {layers = {empty_space = true}},
  protected_from_tile_building = false,
  resistances = {
    {
      type = "impact",
        percent = 100
    },
  },
  hidden = true,
}

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "fusion-reactor",
  width = 3200, height = 3200,
  total_frames = 60,
  shadow_width = 700, shadow_height = 600,
})

local crafting_category = {
  type = "recipe-category",
  name = mod_name,
}

local crafter = {
  type = "assembling-machine",
  name = mod_name,
  icon = skin.icon,

  selection_box = {{-3.0, -3.0}, {3.0, 3.0}},
  collision_box = {{-2.8, -2.8}, {2.8, 2.8}},

  crafting_categories = {crafting_category.name},
  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  energy_usage = "1GW",
  energy_source = {type = "void"},
  minable = {mining_time = 1},

  surface_conditions =
  {
    {
      property = "gravity",
      min = 0,
      max = 0
    }
  },

  flags = {"player-creation"},
}

local item = table.deepcopy(data.raw["item"]["assembling-machine-3"])
item.name = mod_name
item.icon = skin.icon
item.subgroup = "space-rocket"
item.order = "c[shield-generator]"
item.stack_size = 1
item.weight = 1000*kg

crafter.minable.result = item.name
item.place_result = crafter.name

local recipe = {
  type = "recipe",
  name = item.name,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "stone-wall", amount = 1},
    {type = "item", name = "space-platform-foundation", amount = 1},
  },
  energy_required = 60,
  results = {{type="item", name=item.name, amount=1}}
}

local technology = {
  type = "technology",
  name =  mod_name,
  icons = skin.technology_icons,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = recipe.name
    }
  },
  prerequisites = {"stone-wall", "space-platform"},
  unit =
  {
    count = 250,
    ingredients = {{"automation-science-pack", 1}},
    time = 30
  }
}

local shield = {
  type = "recipe",
  name = mod_prefix .. "shield",
  icons = {util.empty_icon()},
  energy_required = 1,
  ingredients = {},
  results = {},
  category = crafting_category.name,
  hidden = true
}

crafter.fixed_recipe = shield.name
crafter.fixed_quality = "normal"

data:extend{simple_entity, crafter, crafting_category, item, recipe, technology, shield}
