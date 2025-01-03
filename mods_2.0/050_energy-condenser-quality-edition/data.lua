local a_9x9_entity = data.raw["rocket-silo"]["rocket-silo"]

local entity = {
  type = "furnace",
  name = "quality-disruptor",
  icon = "__energy-condenser-quality-edition__/graphics/disruptor/disruptor-icon.png",

  selection_box = table.deepcopy(a_9x9_entity.selection_box),
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  health = 2500,

  source_inventory_size = 1,
  result_inventory_size = 1,
  -- custom_input_slot_tooltip_key

  module_slots = 3,
  effect_receiver = { base_effect = { quality = 1 }},
  allowed_effects = {"consumption", "speed", "pollution", "quality"},

  crafting_speed = 3,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 5 }
  },
  energy_usage = "2500kW",

  crafting_categories = data.raw["furnace"]["recycler"].crafting_categories,

  graphics_set = require("graphics.disruptor.pictures").graphics_set,
}

local item = {
  type = "item",
  name = "quality-disruptor",
  icon = "__energy-condenser-quality-edition__/graphics/disruptor/disruptor-icon.png",

  stack_size = 10,
  order = "e[quality-disruptor]",
  subgroup = "smelting-machine",

  weight = 200 * kg,
}

item.place_result = entity.name
entity.minable = {mining_time = 0.3, result = item.name}

local recipe = {
  type = "recipe",
  name = "quality-disruptor",
  ingredients =
  {
    {type = "item", name = "assembling-machine-2", amount = 9},
    {type = "item", name = "copper-cable", amount = 100},
    {type = "item", name = "battery", amount = 50},
    {type = "item", name = "iron-gear-wheel", amount = 25},
  },
  results = {{type="item", name=item.name, amount=1}},
  energy_required = 3,
  enabled = true
}

data:extend({entity, item, recipe})
