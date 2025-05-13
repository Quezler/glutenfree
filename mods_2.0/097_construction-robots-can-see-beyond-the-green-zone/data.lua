require("shared")

local entity = {
  type = "roboport",
  name = mod_prefix .. "roboport",
  icon = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-icon.png",

  selection_box = table.deepcopy(data.raw["roboport"]["roboport"].selection_box),
  collision_box = table.deepcopy(data.raw["roboport"]["roboport"].collision_box),

  flags = {"placeable-player", "player-creation"},

  base = {
    layers = {
      {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-shadow.png",
        width = 500, height = 350,
        scale = 0.5,
        draw_as_shadow = true,
      }
    }
  },
  base_animation = {
    layers = {
      {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-animation-1.png",
        width = 2160 / 8, height = 2480 / 8,
        line_length = 8,
        frame_count = 64,
        animation_speed = 0.5,
        scale = 0.5,
      },
      {
        filename = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-hr-emission-1.png",
        width = 2160 / 8, height = 2480 / 8,
        line_length = 8,
        frame_count = 64,
        animation_speed = 0.5,
        scale = 0.5,
        blend_mode = "additive",
        draw_as_glow = true,
      },
    }
  },
  base_patch = util.empty_sprite(),

  max_health = 750,
  minable = {mining_time = 0.2, result = mod_prefix .. "roboport"},

  charge_approach_distance = 0,
  charging_energy = "0kW",

  door_animation_up = util.empty_sprite(),
  door_animation_down = util.empty_sprite(),

  -- energy_source = {
  --   type = "electric",
  --   usage_priority = "secondary-input",
  --   input_flow_limit = "2GW",
  --   buffer_capacity = "10GJ"
  -- },
  -- energy_usage = "1GW",
  -- recharge_minimum = "9GW",

  energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    input_flow_limit = "1GW",
    buffer_capacity = "1GJ"
  },
  energy_usage = "250MW",
  recharge_minimum = "750MW",


  radar_range = 2,
  logistics_radius = 0,
  construction_radius = 2000000, -- can cover the rest of the map from anywhere

  draw_logistic_radius_visualization = false,
  draw_construction_radius_visualization = false,

  recharging_animation = util.empty_sprite(),
  material_slots_count = 0,
  request_to_open_door_timeout = 0,
  robot_slots_count = 0,
  spawn_and_station_height = 0,
}

local item = {
  type = "item",
  name = mod_prefix .. "roboport",
  icon = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-icon.png",

  subgroup = "logistic-network",
  order = "c[signal]-b[cybernetic-roboport]",

  place_result = entity.name,

  stack_size = 1,
  weight = 1000 * kg,
}

local recipe = {
  type = "recipe",
  name = mod_prefix .. "roboport",
  enabled = false,
  energy_required = 10,
  ingredients =
  {
    {type = "item", name = "processing-unit", amount = 250},
    {type = "item", name = "roboport", amount = 1},
    {type = "item", name = "small-lamp", amount = 2},
  },
  results = {{type="item", name=item.name, amount=1}}
}

local technology = {
  type = "technology",
  name = mod_prefix .. "roboport",
  icon = mod_directory .. "/graphics/cybernetics-facility/base/cybernetics-facility-icon-big.png",
  icon_size = 640,
  effects =
  {
    {type = "unlock-recipe", recipe = recipe.name},
  },
  prerequisites = {"construction-robotics", "processing-unit"},
  unit =
  {
    count = 500,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1}
    },
    time = 30
  }
}

data:extend{entity, item, recipe, technology}
