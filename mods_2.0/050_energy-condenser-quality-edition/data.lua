require("shared")

local sounds = require("__base__.prototypes.entity.sounds")

local a_9x9_entity = data.raw["rocket-silo"]["rocket-silo"]
local a_3x3_entity = data.raw["assembling-machine"]["assembling-machine-2"]

local skins = {
  ["Disruptor"] = {
    icon = mod_directory .. "/graphics/disruptor/disruptor-icon.png",
    graphics_set = require("graphics.disruptor.pictures").graphics_set,
  },
  ["Research center"] = {
    icon = mod_directory .. "/graphics/research-center/research-center-icon.png",
    graphics_set = require("graphics.research-center.pictures").graphics_set,
  },
}
local skin = skins[settings.startup[mod_prefix .. "skin"].value]

local crafter_entity = {
  type = "assembling-machine",
  name = mod_prefix .. "crafter",
  icon = skin.icon,

  selection_priority = 51,
  drawing_box_vertical_extension = 0.5,
  selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  health = 2500,

  module_slots = 3,
  effect_receiver = { base_effect = { quality = settings.startup[mod_prefix .. "base-quality"].value / 100 }},
  allowed_effects = {"consumption", "speed", "pollution", "quality"},

  crafting_speed = 2,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 10 }
  },
  energy_usage = "2500kW",

  crafting_categories = {mod_prefix .. "recipe-category"},
  fixed_recipe = mod_prefix .. "recipe",
  fixed_quality = "normal",
  icon_draw_specification = {scale = 0},
  icons_positioning = {
    {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 2.0}, scale = 1}
  },

  graphics_set = skin.graphics_set,
  perceived_performance = {minimum = 1},

  open_sound = sounds.machine_open,
  close_sound = sounds.machine_close,
  -- working_sound = space_age_sounds.electromagnetic_plant,

  minable = table.deepcopy(a_9x9_entity.minable),
  quality_indicator_scale = 0,

  flags = {"player-creation", "no-automated-item-insertion", "no-automated-item-removal"},
}

local crafter_item = {
  type = "item",
  name = mod_prefix .. "crafter",
  icon = skin.icon,

  stack_size = 10,
  order = "e[quality-condenser--crafter]",
  subgroup = "smelting-machine",

  weight = 200 * kg,
}

crafter_item.place_result = crafter_entity.name
crafter_entity.minable = {mining_time = 0.3, result = crafter_item.name}

local crafter_recipe = {
  type = "recipe",
  name = mod_prefix .. "crafter",
  ingredients =
  {
    {type = "item", name = "assembling-machine-2", amount = 9},
    {type = "item", name = "copper-cable", amount = 100},
    {type = "item", name = "battery", amount = 50},
    {type = "item", name = "iron-gear-wheel", amount = 25},
  },
  results = {{type="item", name=crafter_item.name, amount=1}},
  energy_required = 3,
  enabled = true,
}

data:extend({crafter_entity, crafter_item, crafter_recipe})

local container_entity = {
  type = "container",
  name = mod_prefix .. "container",
  icon = skin.icon,

  inventory_size = 20,
  inventory_type = "normal",

  selection_box = table.deepcopy(a_9x9_entity.selection_box),
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  collision_mask = {layers = {}},
  health = 2500,

  minable = table.deepcopy(a_9x9_entity.minable),
}
container_entity.minable.result = nil

data:extend({container_entity})

require("prototypes.surface")
require("prototypes.recipe")
