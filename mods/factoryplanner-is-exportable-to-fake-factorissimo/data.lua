local mod_prefix = 'fietff-'
local mod_path = '__factoryplanner-is-exportable-to-fake-factorissimo__'
local shared = require('shared')

local function create_container(config)
  local container = {
    type = 'container',
    name = mod_prefix .. 'container-' .. config.i,

    localised_name = {"entity-name.fietff-container-i", config.i},
  
    icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', config.i),
    icon_size = 64,

    max_health = 500 + (1500 * config.i),
  
    collision_box = config.collision_box,
    selection_box = config.selection_box,
    vehicle_impact_sound = { filename = '__base__/sound/car-stone-impact.ogg', volume = 1.0 },
  
    -- inventory_size = 10 * config.i,
    inventory_size = 40,
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
          filename = string.format(mod_path .. '/graphics/factory/factory-%d-alt.png', config.i),
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

data:extend{container_1, container_2, container_3}

local item_1 = {
  type = 'item',
  name = mod_prefix .. 'item-' .. 1,
  flags = {'hidden', 'only-in-cursor'},
  icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', 1),
  icon_size = 64,
  stack_size = 1,
  place_result = container_1.name,
}

item_1.name = 'er:screenshot-camera' -- easiest way to allow space exploration's remote view to hold one :)

data:extend{item_1}

local interface_1 = {
  type = 'electric-energy-interface',
  name = mod_prefix .. 'electric-energy-interface-' .. 1,
  localised_name = {"", {"entity-name.fietff-container-i", 1}, ' ', '(power)'},
  icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', 1),
  icon_size = 64,

  collision_mask = {},
  collision_box = {{-3.8, -3.8 - shared.electric_energy_interface_1_y_offset}, {3.8, 3.8 - shared.electric_energy_interface_1_y_offset}},
  selection_box = {{-0.4, -0.3}, {0.4, 0.3}},
  selection_priority = 51,

  max_health = 10 * 1, -- mimic the storage size, because why not

  flags = {
    'placeable-off-grid',
  },

  -- gui_mode = 'all',
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input"
  },

  picture = {
    filename = mod_path .. '/graphics/entities/electric-energy-interface.png',
    width = 30,
    height = 20,
    scale = 0.5,
  }
}

data:extend{interface_1}

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

local assembling_machine = {
  type = 'assembling-machine',
  name = mod_prefix .. 'assembling-machine-' .. 1,
  localised_name = {"", {"entity-name.fietff-container-i", 1}, ' ', '(rent)'},
  icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', 1),
  icon_size = 64,

  flags = {
    'not-on-map',
    'hide-alt-info',
    'no-automated-item-removal',
    'no-automated-item-insertion',
  },

  collision_mask = {},
  collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selection_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selectable_in_game = false,

  crafting_categories = {category.name},
  fixed_recipe = recipe.name,
  crafting_speed = 1,
  energy_usage = "100kW",
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input",
    drain = '0kW',
  },

  bottleneck_ignore = true,
}

data:extend{coin, category, recipe, assembling_machine}

local combinator = {
  type = 'constant-combinator',
  name = mod_prefix .. 'constant-combinator-' .. 1,
  collision_mask = {},
  collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selection_box = {{-4.0, -4.0}, {4.0, 4.0}},
  selection_priority = 48,
  selectable_in_game = false,

  -- item_slot_count = 4294967295,
  item_slot_count = 40,
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

data:extend{combinator}

assert(combinator.item_slot_count == container_1.inventory_size)
