local mod_prefix = 'fietff-'
local mod_path = '__factoryplanner-is-exportable-to-fake-factorissimo__'
local shared = require('shared')

local collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile"}
local icon_file_path = '/graphics/icon/factory-%d.png'
local icon_size = 64
local entity_file_path = '/graphics/factory/factory-%d.png'

local space_exploration_mode = mods['space-exploration']
-- space_exploration_mode = false

if space_exploration_mode then
  table.insert(collision_mask, 'ground-tile')
  icon_file_path = '/graphics/icon/factory-%d-space.png'
  icon_size = 32
  entity_file_path = '/graphics/factory/factory-%d-space.png'
end

local function create_container(config)
  local container = {
    type = 'container',
    name = mod_prefix .. 'container-' .. config.i,

    localised_name = {"entity-name.fietff-container-i", config.i},
  
    icon = string.format(mod_path .. icon_file_path, config.i),
    icon_size = icon_size,

    max_health = 500 + (1500 * config.i),
  
    collision_mask = collision_mask,
    collision_box = config.collision_box,
    selection_box = config.selection_box,
    vehicle_impact_sound = { filename = '__base__/sound/car-stone-impact.ogg', volume = 1.0 },
  
    inventory_size = 40 * config.i,
    enable_inventory_bar = false,
  
    flags = {
      'placeable-player',
      'player-creation',
      'hide-alt-info',
    },
  
    minable = {mining_time = 0.75 * config.i},
    
    picture = {
      layers = {
        {
          filename = string.format(mod_path .. '/graphics/factory/factory-%d-shadow.png', config.i),
          draw_as_shadow = true
        },
        {
          filename = string.format(mod_path .. entity_file_path, config.i),
          shift = config.shift,
        }
      }
    },

    se_allow_in_space = true,
  }

  for _, layer in ipairs(container.picture.layers) do
    for key, value in pairs(config.layers_inject) do
      layer[key] = value
    end
  end

  circuit_connector_definition = circuit_connector_definitions.create(universal_connector_template,
    {
      { variation = config.circuit_variation, main_offset = config.circuit_main_offset, shadow_offset = util.by_pixel(0, 0), show_shadow = false },
    }
  )

  container.circuit_wire_connection_point = circuit_connector_definition.points
  container.circuit_connector_sprites = circuit_connector_definition.sprites
  container.circuit_wire_max_distance = default_circuit_wire_max_distance

  return container
end

local container_1 = create_container({
  i = 1,
  collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selection_box = {{-3.8, -3.8}, {3.8, 3.8}},
  layers_inject = {
    width = 416,
    height = 320,
    shift = {1.5, 0},
  },
  circuit_variation = 1,
  circuit_main_offset = util.by_pixel(3, -72),
})

local container_2 = create_container({
  i = 2,
  collision_box = {{-5.8, -5.8}, {5.8, 5.8}},
  selection_box = {{-5.8, -5.8}, {5.8, 5.8}},
  layers_inject = {
    width = 544,
    height = 448,
    shift = {1.5, 0},
  },
  circuit_variation = 2,
  circuit_main_offset = util.by_pixel(0, -72),
})

local container_3 = create_container({
  i = 3,
  collision_box = {{-7.8, -7.8}, {7.8, 7.8}},
  selection_box = {{-7.8, -7.8}, {7.8, 7.8}},
  layers_inject = {
    width = 704,
    height = 608,
    shift = {2, -0.09375},
  },
  circuit_variation = 4,
  circuit_main_offset = util.by_pixel(-4, -72),
})

if space_exploration_mode then
  local data_util = require('__space-exploration__.data_util')
  data_util.collision_description(container_1)
  data_util.collision_description(container_2)
  data_util.collision_description(container_3)
end

data:extend{container_1, container_2, container_3}

local function create_item(config)
  return {
    type = 'item',
    name = mod_prefix .. 'item-' .. config.i,
    flags = {'hidden', 'only-in-cursor'},
    icons = {{icon = string.format(mod_path .. icon_file_path, config.i), icon_size = icon_size}},
    stack_size = 1,
    place_result = mod_prefix .. 'container-' ..config.i,
  }
end

local item_1 = create_item({i = 1})
local item_2 = create_item({i = 2})
local item_3 = create_item({i = 3})

data:extend{item_1, item_2, item_3}

local function create_interface(config)
  local container = data.raw['container'][mod_prefix .. 'container-' .. config.i]
  return {
    type = 'electric-energy-interface',
    name = mod_prefix .. 'electric-energy-interface-' .. config.i,
    localised_name = {"", {"entity-name.fietff-container-i", config.i}, ' ', '(power)'},
    icon = string.format(mod_path .. icon_file_path, config.i),
    icon_size = icon_size,

    collision_mask = {},
    collision_box = {
      {container.collision_box[1][1], container.collision_box[1][2] - shared[string.format('electric_energy_interface_%d_y_offset', config.i)]},
      {container.collision_box[2][1], container.collision_box[2][2] - shared[string.format('electric_energy_interface_%d_y_offset', config.i)]},
    },
    selection_box = {{-0.4, -0.3}, {0.4, 0.3}},
    selection_priority = 51,

    max_health = container.inventory_size, -- mimic the storage size, because why not

    flags = {
      'placeable-off-grid',
      'not-rotatable',
    },

    -- gui_mode = 'all',
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      render_no_power_icon = false,
      render_no_network_icon = false,
    },

    picture = {
      filename = mod_path .. '/graphics/entities/electric-energy-interface.png',
      width = 30,
      height = 20,
      scale = 0.5,
    }
  }
end

local interface_1 = create_interface({i = 1})
local interface_2 = create_interface({i = 2})
local interface_3 = create_interface({i = 3})

data:extend{interface_1, interface_2, interface_3}

local coin = {
  type = 'item',
  name = mod_prefix .. 'coin',

  flags = {'hidden'},

  icon = data.raw['item']['coin'].icon,
  icon_size = data.raw['item']['coin'].icon_size,

  stack_size = 60,
}

local category = {
  type = 'recipe-category',
  name = mod_prefix .. 'clock',
}

local recipe = {
  type = 'recipe',
  name = mod_prefix .. 'seconds',
  category = category.name,
  hide_from_stats = true,
  hide_from_player_crafting = true,

  ingredients = {},
  results = {{
    type = "item",
    name = coin.name,
    amount = 1,
  }},
  energy_required = 1,
}

data:extend{coin, category, recipe}

local function create_assembler(config)
  local container = data.raw['container'][mod_prefix .. 'container-' .. config.i]
  return {
    type = 'assembling-machine',
    name = mod_prefix .. 'assembling-machine-' .. config.i,
    localised_name = {"", {"entity-name.fietff-container-i", config.i}, ' ', '(rent)'},
    icon = string.format(mod_path .. icon_file_path, config.i),
    icon_size = icon_size,

    flags = {
      'not-on-map',
      'hide-alt-info',
      'no-automated-item-removal',
      'no-automated-item-insertion',
    },

    collision_mask = {},
    collision_box = container.collision_box,
    selection_box = container.selection_box,
    selectable_in_game = false,

    crafting_categories = {category.name},
    fixed_recipe = recipe.name,
    crafting_speed = 1,
    energy_usage = '100' .. string.rep('0', config.i) .. 'kW',
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = '0kW',
    },

    bottleneck_ignore = true,
  }
end

local assembler_1 = create_assembler({i = 1})
local assembler_2 = create_assembler({i = 2})
local assembler_3 = create_assembler({i = 3})

data:extend{assembler_1, assembler_2, assembler_3}

local function create_combinator(config)
  local container = data.raw['container'][mod_prefix .. 'container-' .. config.i]
  return {
    type = 'constant-combinator',
    name = mod_prefix .. 'constant-combinator-' .. config.i,
    collision_mask = {},
    collision_box = container.collision_box,
    selection_box = {
      {container.selection_box[1][1] - 0.2, container.selection_box[1][2] + 0.2},
      {container.selection_box[2][1] - 0.2, container.selection_box[2][2] + 0.2},
    },
    selection_priority = 48,
    selectable_in_game = false,

    item_slot_count = container.inventory_size,
    energy_source = {type = "void"},

    circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
    activity_led_light_offsets = data.raw['constant-combinator']['constant-combinator'].activity_led_light_offsets,
    circuit_wire_max_distance = data.raw['constant-combinator']['constant-combinator'].circuit_wire_max_distance,
    draw_circuit_wires = false,

    flags = {
      'not-on-map',
      'hide-alt-info',
    },
  }
end

local combinator_1 = create_combinator({i = 1})
local combinator_2 = create_combinator({i = 2})
local combinator_3 = create_combinator({i = 3})

data:extend{combinator_1, combinator_2, combinator_3}

local function create_fluid_combinator(config)
  local container = data.raw['container'][mod_prefix .. 'container-' .. config.i]
  return {
    type = 'constant-combinator',
    name = mod_prefix .. 'constant-combinator-fluids-' .. config.i,
    collision_mask = {},
    collision_box = container.collision_box,
    selection_box = {
      {container.selection_box[1][1] - 0.3, container.selection_box[1][2] + 0.3},
      {container.selection_box[2][1] - 0.3, container.selection_box[2][2] + 0.3},
    },
    selection_priority = 47,
    selectable_in_game = false,

    item_slot_count = 20 + (10 * config.i), -- 30 small, 40 medium, 50 large
    energy_source = {type = "void"},

    circuit_wire_connection_points = data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points,
    activity_led_light_offsets = data.raw['constant-combinator']['constant-combinator'].activity_led_light_offsets,
    circuit_wire_max_distance = data.raw['constant-combinator']['constant-combinator'].circuit_wire_max_distance,
    draw_circuit_wires = false,

    flags = {
      'not-on-map',
      'hide-alt-info',
    },
  }
end

local fluid_combinator_1 = create_fluid_combinator({i = 1})
local fluid_combinator_2 = create_fluid_combinator({i = 2})
local fluid_combinator_3 = create_fluid_combinator({i = 3})

data:extend{fluid_combinator_1, fluid_combinator_2, fluid_combinator_3}

data:extend{
  {
    type = "recipe-category",
    name = "fietff-unlocks"
  }
}

local function create_recipe(config)
  return {
    type = 'recipe',
    category = 'fietff-unlocks',
    name = mod_prefix .. 'item-' .. config.i .. '-unlock',
    localised_name = {"entity-name.fietff-container-i", config.i},

    icon = string.format(mod_path .. icon_file_path, config.i),
    icon_size = icon_size,

    ingredients = {},
    result = mod_prefix .. 'item-' .. config.i,
    enabled = true,
    hide_from_player_crafting = true,
    energy_required = 1,
  }
end

local recipe_1 = create_recipe({i = 1})
local recipe_2 = create_recipe({i = 2})
local recipe_3 = create_recipe({i = 3})

data:extend{recipe_1, recipe_2, recipe_3}

data:extend{
  {
    type = 'custom-input',
    name =  mod_prefix .. 'rotate',
    key_sequence = '',
    linked_game_control = 'rotate',
  },
  {
    type = 'custom-input',
    name =  mod_prefix .. 'reverse-rotate',
    key_sequence = '',
    linked_game_control = 'reverse-rotate',
  }
}
