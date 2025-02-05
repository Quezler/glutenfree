require("shared")

local sounds = require("__base__.prototypes.entity.sounds")

local a_9x9_entity = data.raw["rocket-silo"]["rocket-silo"]
local a_3x3_entity = data.raw["assembling-machine"]["assembling-machine-2"]

local skins = {
  ["Disruptor"] = {
    name = "disruptor",
    width = 4720, height = 4720,
    total_frames = 40 + 40,
    shadow_width = 1200, shadow_height = 700,
  },
  ["Research center"] = {
    name = "research-center",
    width = 4720, height = 5120,
    total_frames = 40 + 40,
    shadow_width = 1200, shadow_height = 700,
  },
}

local Hurricane = require("graphics.hurricane")
local appearance = settings.startup[mod_prefix .. "skin"].value
local skin = Hurricane.crafter(skins[appearance])

-- a manual modification to block some transparency
if appearance == "Disruptor" then
  table.insert(skin.graphics_set.animation.layers, 1, {
    filename = mod_directory .. "/graphics/disruptor/disruptor-hr-animation-bg.png",
    priority = "high",
    width = 590,
    height = 590,
    frame_count = 1,
    repeat_count = 80,
    scale = 0.5,
    animation_speed = 0.5,
  })
end

local crafter_entity = {
  type = "assembling-machine",
  name = mod_prefix .. "crafter",
  icon = skin.icon,

  selection_priority = 51,
  drawing_box_vertical_extension = 0.5,
  selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  max_health = 1000,

  module_slots = settings.startup[mod_prefix .. "module-slots"].value,
  effect_receiver = { base_effect = { quality = math.floor(settings.startup[mod_prefix .. "base-quality"].value * 10) / 100 }},
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
  -- fixed_recipe = mod_prefix .. "recipe",
  -- fixed_quality = "normal",
  return_ingredients_on_change = false,
  show_recipe_icon_on_map = false,
  icon_draw_specification = {shift = {1 - 0.05, -1 + 0.05}, scale = 4},
  icons_positioning = {
    {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 2.0}, scale = 1},
  },

  graphics_set = skin.graphics_set,
  perceived_performance = {minimum = 1},

  open_sound = sounds.machine_open,
  close_sound = sounds.machine_close,
  working_sound =
  {
    main_sounds =
    {
      {
        sound =
        {
          filename = "__base__/sound/accumulator-working.ogg",
          volume = 10,
        },
        activity_to_volume_modifiers = {offset = 2, inverted = true},
        fade_in_ticks = 4,
        fade_out_ticks = 20
      },
      {
        sound =
        {
          filename = "__base__/sound/accumulator-discharging.ogg",
          volume = 10,
        },
        activity_to_volume_modifiers = {offset = 1},
        fade_in_ticks = 4,
        fade_out_ticks = 20
      }
    },
    max_sounds_per_prototype = 3,
  },

  minable = table.deepcopy(a_9x9_entity.minable),
  -- quality_indicator_shift = {-1, 1}, #7398
  quality_indicator_scale = 0,

  -- circuit_wire_max_distance = 9,

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
    {type = "item", name = "iron-plate", amount = 100},
    {type = "item", name = "iron-gear-wheel", amount = 25},
    {type = "item", name = "steel-plate", amount = 50},
    {type = "item", name = "copper-cable", amount = 200},
    {type = "item", name = "electronic-circuit", amount = 100},
    {type = "item", name = "advanced-circuit", amount = 50},
  },
  results = {{type="item", name=crafter_item.name, amount=1}},
  energy_required = 10,
  enabled = false,
}

local crafter_technology = {
  type = "technology",
  name = "quality-condenser", -- todo: shared.lua
  icons = skin.technology_icons,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = crafter_recipe.name
    }
  },
  prerequisites = {"advanced-circuit"},
  unit =
  {
    count = 1000,
    ingredients =
    {
      -- it only costs time
    },
    time = 60
  }
}

data:extend({crafter_entity, crafter_item, crafter_recipe, crafter_technology})

local container_entity = {
  type = "container",
  name = mod_prefix .. "container",
  icon = skin.icon,

  inventory_size = 20,
  inventory_type = "normal",

  selection_box = table.deepcopy(a_9x9_entity.selection_box),
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  collision_mask = {layers = {}},
  max_health = 10,

  minable = table.deepcopy(a_9x9_entity.minable),

  icon_draw_specification = {scale = 0, scale_for_many = 0},
  -- quality_indicator_scale = 0, #7398
  hidden = true,
}
container_entity.minable.result = nil

data:extend({container_entity})

require("prototypes.surface")
require("prototypes.recipe")
