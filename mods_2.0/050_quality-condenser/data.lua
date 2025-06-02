require("shared")

local sounds = require("__base__.prototypes.entity.sounds")

local a_9x9_entity = data.raw["rocket-silo"]["rocket-silo"]
local a_3x3_entity = data.raw["assembling-machine"]["assembling-machine-2"]

local Hurricane = require("graphics.hurricane")
local skin = Hurricane.crafter({
  name = "research-center",
  width = 4720, height = 5120,
  total_frames = 40 + 40,
  shadow_width = 1200, shadow_height = 700,
  shift = {0, -0.6},
})

local module_slots = settings.startup[mod_prefix .. "module-slots"].value
local module_slot_scale = {
  [1] = 1.75,
  [2] = 1.50,
  [3] = 1.25,
  -- default = 1
}

local crafter_entity = {
  type = "assembling-machine",
  name = mod_name,
  icon = skin.icon,

  selection_priority = 51,
  drawing_box_vertical_extension = 1,
  selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  max_health = 1000,

  module_slots = module_slots,
  allowed_effects = {"consumption", "speed", "pollution", "quality"},

  crafting_speed = 2,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = 10 }
  },
  energy_usage = settings.startup[mod_prefix .. "energy-usage"].value,

  crafting_categories = {mod_prefix .. "recipe-category"},
  fixed_recipe = mod_prefix .. "recipe",
  fixed_quality = "normal",
  -- return_ingredients_on_change = false,
  show_recipe_icon_on_map = false,
  -- icon_draw_specification = {shift = {1 - 0.05, -1 + 0.05}, scale = 4},
  icon_draw_specification = {scale = 0},
  icons_positioning = {
    {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 1.25}, scale = module_slot_scale[module_slots] or 1},
    -- {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 1}, scale = 1.75, max_icons_per_row = 3},
  },

  graphics_set = skin.graphics_set,
  perceived_performance = {minimum = 1},

  open_sound = sounds.machine_open,
  close_sound = sounds.machine_close,
  working_sound =
  {
    sound = {filename = mod_directory .. "/sound/recycler/recycler-loop.ogg", volume = 0.7 * 2}, -- allowed because of feature flag
    fade_in_ticks = 4,
    fade_out_ticks = 20,
    max_sounds_per_prototype = 2 * 2,
  },

  minable = {mining_time = 1},
  quality_indicator_shift = {-1, 1},

  flags = {"player-creation", "no-automated-item-insertion", "no-automated-item-removal"},
}

local crafter_item = {
  type = "item",
  name = mod_name,
  icon = skin.icon,

  stack_size = 10,
  order = "e[quality-condenser]",
  subgroup = "smelting-machine",

  weight = 200 * kg,
}

crafter_item.place_result = crafter_entity.name
crafter_entity.minable.result = crafter_item.name

local crafter_recipe = {
  type = "recipe",
  name = mod_name,
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
  name = mod_name,
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
    count = 250,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  }
}

data:extend({crafter_entity, crafter_item, crafter_recipe, crafter_technology})

local container_entity = {
  type = "container",
  name = mod_prefix .. "container",
  icon = skin.icon,

  inventory_size = 20,
  inventory_type = "normal",
  flags = {"player-creation", "not-on-map", "not-deconstructable"},

  open_sound = sounds.metallic_chest_open,
  close_sound = sounds.metallic_chest_close,

  selection_box = table.deepcopy(a_9x9_entity.selection_box),
  collision_box = table.deepcopy(a_9x9_entity.collision_box),
  collision_mask = {layers = {}},
  max_health = 10,

  minable = {mining_time = 1},

  circuit_wire_max_distance = default_circuit_wire_max_distance,
  circuit_connector = circuit_connector_definitions.create_single
  (
    universal_connector_template,
    {variation = 22, main_offset = util.by_pixel(-85, 127), shadow_offset = util.by_pixel(-90, 127)}
  ),

  icon_draw_specification = {scale = 0, scale_for_many = 0},
  quality_indicator_scale = 0,
  hidden = true,
}

data:extend({container_entity})

require("prototypes.surface")
require("prototypes.recipe")

local beacon_interface = table.deepcopy(data.raw["beacon"]["beacon-interface--beacon-tile"])
beacon_interface.name = mod_prefix .. "beacon-interface"
data:extend{beacon_interface}

data.raw["gui-style"]["default"].quality_condenser_tabbed_pane =
{
  type = "tabbed_pane_style",
  parent = "tabbed_pane",
  tab_content_frame =
  {
    type = "frame_style",
    parent = "invisible_frame", -- https://discord.com/channels/139677590393716737/1217401074877599745/1339208959512543324
  }
}
