require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local Hurricane = require("graphics/hurricane")
local skin = Hurricane.crafter({
  name = "radio-station",
  width = 1280, height = 870,
  total_frames = 20, rows = 3, -- custom
  shadow_width = 400, shadow_height = 350,
  shift = {0, 0.25}, -- custom
})

local entity = {
  type = "assembling-machine",
  name = mod_name,

  icon = skin.icon,
  graphics_set = skin.graphics_set,

  crafting_speed = 1,
  selection_box = {{-1.5, -1.5}, {1.5, 2.5}},
  collision_box = {{-1.2, -1.2}, {1.2, 2.2}},
  tile_height = 3.5,
  max_health = 500,

  energy_usage = "1kW",
  energy_source = {type = "void"},

  icon_draw_specification = {shift = {0, 1}, scale = 0.75},

  flags = {"player-creation", "placeable-player", "not-rotatable"},
  circuit_wire_max_distance = 9,
}

local proxy = {
  type = "proxy-container",
  name = mod_prefix .. "proxy-container",

  icons = {{icon = entity.icon, tint = proxy_tint}},
  selection_box = entity.selection_box,
  collision_box = entity.collision_box,
  collision_mask = {layers = {}},
  tile_height = 3.5,

  flags = {"player-creation"},
  draw_inventory_content = false,
  selectable_in_game = false,
  selection_priority = 49,
  hidden = true,
}

local item = {
  type = "item",
  name = mod_name,

  icon = skin.icon,
  subgroup = "storage",
  order = "c[character-inventory-uplink]",

  stack_size = 5,
  weight = 200*kg,
  place_result = entity.name,
}
entity.minable = {mining_time = 0.5, result = item.name}

do -- internal recipe
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
    hidden = true,
  }

  entity.crafting_categories = {recipe_category.name}
  entity.fixed_recipe = recipe.name
  entity.fixed_quality = "normal"

  data:extend{recipe_category, recipe}
end

local recipe = {
  type = "recipe",
  name = mod_name,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "iron-plate", amount = 100},
    {type = "item", name = "copper-cable", amount = 50},
    {type = "item", name = "electronic-circuit", amount = 25},

  },
  results = {{type="item", name=item.name, amount=1}}
}

local technology = {
  type = "technology",
  name = mod_name,
  icons = skin.technology_icons,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = recipe.name
    }
  },
  prerequisites = {"radar", "circuit-network"},
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

if mods["Krastorio2"] then
  technology.prerequisites = {"kr-sentinel", "circuit-network"}
end

data:extend{entity, proxy, item, recipe, technology}

entity.circuit_connector = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    {variation = 22, main_offset = util.by_pixel(-17.5, 53), shadow_offset = util.by_pixel(-17.5, 53), show_shadow = true},
    {variation = 22, main_offset = util.by_pixel(-17.5, 53), shadow_offset = util.by_pixel(-17.5, 53), show_shadow = true},
    {variation = 22, main_offset = util.by_pixel(-17.5, 53), shadow_offset = util.by_pixel(-17.5, 53), show_shadow = true},
    {variation = 22, main_offset = util.by_pixel(-17.5, 53), shadow_offset = util.by_pixel(-17.5, 53), show_shadow = true},
  }
)

entity.circuit_connector[1].sprites.connector_main = nil
entity.circuit_connector[1].sprites.connector_shadow = nil
entity.circuit_connector[1].sprites.led_red = util.empty_sprite()
entity.circuit_connector[1].sprites.led_green = util.empty_sprite()
entity.circuit_connector[1].sprites.led_blue = util.empty_sprite()
entity.circuit_connector[1].sprites.led_blue_off = nil
