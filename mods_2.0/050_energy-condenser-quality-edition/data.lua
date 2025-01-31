local sounds = require("__base__.prototypes.entity.sounds")

local a_9x9_entity = data.raw["rocket-silo"]["rocket-silo"]
local a_3x3_entity = data.raw["assembling-machine"]["assembling-machine-2"]

local mod_prefix = "quality-disruptor--"
local mod_directory = "__energy-condenser-quality-edition__"

local furnace_entity = {
  type = "furnace",
  name = mod_prefix .. "furnace",
  icon = mod_directory .. "/graphics/disruptor/disruptor-icon.png",

  selection_priority = 51,
  drawing_box_vertical_extension = 0.5,
  selection_box = {{-3, -3}, {3, 3}},
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  health = 2500,

  source_inventory_size = 1,
  result_inventory_size = 1,
  -- custom_input_slot_tooltip_key

  module_slots = 3,
  effect_receiver = { base_effect = { quality = 1 }},
  allowed_effects = {"consumption", "speed", "pollution", "quality"},

  crafting_speed = 2,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 10 }
  },
  energy_usage = "2500kW",

  crafting_categories = data.raw["furnace"]["recycler"].crafting_categories,

  graphics_set = require("graphics.disruptor.pictures").graphics_set,
  perceived_performance = {minimum = 1},

  open_sound = sounds.machine_open,
  close_sound = sounds.machine_close,
  -- working_sound = space_age_sounds.electromagnetic_plant,

  minable = table.deepcopy(a_9x9_entity.minable),
  quality_indicator_scale = 0,
}

local furnace_item = {
  type = "item",
  name = mod_prefix .. "furnace",
  icon = mod_directory .. "/graphics/disruptor/disruptor-icon.png",

  stack_size = 10,
  order = "e[quality-disruptor--furnace]",
  subgroup = "smelting-machine",

  weight = 200 * kg,
}

furnace_item.place_result = furnace_entity.name
furnace_entity.minable = {mining_time = 0.3, result = furnace_item.name}

local furnace_recipe = {
  type = "recipe",
  name = mod_prefix .. "furnace",
  ingredients =
  {
    {type = "item", name = "assembling-machine-2", amount = 9},
    {type = "item", name = "copper-cable", amount = 100},
    {type = "item", name = "battery", amount = 50},
    {type = "item", name = "iron-gear-wheel", amount = 25},
  },
  results = {{type="item", name=furnace_item.name, amount=1}},
  energy_required = 3,
  enabled = true,
}

data:extend({furnace_entity, furnace_item, furnace_recipe})

local container_entity = {
  type = "container",
  name = mod_prefix .. "container",
  icon = mod_directory .. "/graphics/disruptor/disruptor-icon.png",

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
