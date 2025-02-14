require("shared")

local item_sounds = require("__base__.prototypes.item_sounds")

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "pathogen-lab",
  width = 4000, height = 4000,
  total_frames = 60,
  shadow_width = 800, shadow_height = 700,
})

local entity = {
  type = "assembling-machine",
  name = mod_name,
  icon = skin.icon,

  collision_box = {{-3.4, -3.4}, {3.4, 3.4}},
  selection_box = {{-3.5, -3.5}, {3.5, 3.5}},

  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  energy_usage = "1MW",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    emissions_per_minute = { pollution = -100 }
  },

  crafting_categories = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"].crafting_categories),
  icon_draw_specification = {shift = {0.45, -0.375}, scale = 1.5},
}

local item = {
  type = "item",
  name = mod_name,
  icon = skin.icon,
  subgroup = "agriculture",
  order = "c["..mod_name.."]",
  inventory_move_sound = item_sounds.mechanical_inventory_move,
  pick_sound = item_sounds.mechanical_inventory_pickup,
  drop_sound = item_sounds.mechanical_inventory_move,
  stack_size = 1,
}

item.place_result = entity.name
entity.minable = {mining_time = 0.5, result = item.name}

recipe = {
  type = "recipe",
  name = mod_name,
  category = "organic-or-assembling",
  order = "c["..mod_name.."]",
  -- auto_recycle = false,
  enabled = false,
  -- allow_productivity = true,
  -- result_is_always_fresh = true,
  -- hide_from_signal_gui = true,
  energy_required = 30,
  ingredients =
  {
    {type = "item", name = "nutrients", amount = 50},
    {type = "item", name = "biter-egg", amount =  2},
    {type = "item", name = "iron-plate", amount = 100},
    {type = "item", name = "biochamber", amount = 1},
  },
  results =
  {
    {type = "item", name = item.name, amount = 1},
  },
  crafting_machine_tint = -- same as pentapod egg
  {
    primary = {r = 45, g = 129, b = 86, a = 1.000},
    secondary = {r = 122, g = 75, b = 156, a = 1.000},
  }
}

local biter_egg_handling = data.raw["technology"]["biter-egg-handling"]
biter_egg_handling.effects = biter_egg_handling.effects or {}
table.insert(biter_egg_handling.effects, {
  type = "unlock-recipe",
  recipe = recipe.name,
})

local make_optical_fiber_pictures = function (path, name_prefix, data, draw_as_glow)
  for _, t in pairs(data) do
    t.ommit_number = true
    t.width = t.width or 128
    t.height = t.height or 128
    t.shift = t.shift or {1, 1}
  end
  ---@diagnostic disable-next-line: undefined-global
  return make_heat_pipe_pictures(path, name_prefix, data, draw_as_glow)
end

local artery = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
artery.name = mod_prefix .. "artery"
artery.icon = mod_directory .. "/graphics/icons/artery.png"
artery.connection_sprites = make_optical_fiber_pictures(mod_directory .. "/graphics/entity/artery/", "artery",
{
  single = { name = "straight-vertical-single", width = 160, height = 160, shift = {1.25, 1.25} },
  straight_vertical = {},
  straight_horizontal = {},
  corner_right_up = { name = "corner-up-right" },
  corner_left_up = { name = "corner-up-left" },
  corner_right_down = { name = "corner-down-right" },
  corner_left_down = { name = "corner-down-left" },
  t_up = {},
  t_down = {},
  t_right = {},
  t_left = {},
  cross = {},
  ending_up = {},
  ending_down = {},
  ending_right = {},
  ending_left = {},
})
artery.minable = nil
artery.heat_buffer.connections = {}
artery.hidden = true
data:extend{entity, item, recipe, artery}
