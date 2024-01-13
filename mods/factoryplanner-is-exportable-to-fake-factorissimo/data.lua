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
  
    inventory_size = 10 * config.i,
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
    }
  }

  for _, layer in ipairs(container.picture.layers) do
    for key, value in pairs(config.layers_inject) do
      layer[key] = value
    end
  end

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
})

local container_2 = create_container({
  i = 2,
  collision_box = {{-5.8, -5.8}, {5.8, 5.8}},
  selection_box = {{-5.8, -5.8}, {5.8, 5.8}},
  layers_inject = {
    width = 544,
    height = 448,
    shift = {1.5, 0},
  }
})

local container_3 = create_container({
  i = 3,
  collision_box = {{-7.8, -7.8}, {7.8, 7.8}},
  selection_box = {{-7.8, -7.8}, {7.8, 7.8}},
  layers_inject = {
    width = 704,
    height = 608,
    shift = {2, -0.09375},
  }
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

data:extend{item_1}

local interface_1 = {
  type = 'electric-energy-interface',
  name = mod_prefix .. 'electric-energy-interface-' .. 1,
  localised_name = {"entity-name.fietff-container-i", 1},
  icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', 1),
  icon_size = 64,

  collision_box = {{-3.8, -3.8 - shared.electric_energy_interface_1_y_offset}, {3.8, 3.8 - shared.electric_energy_interface_1_y_offset}},
  selection_box = {{-0.4, -0.3}, {0.4, 0.3}},
  selection_priority = 51,

  max_health = 10 * 1, -- mimic the storage size, because why not

  flags = {
    'placeable-off-grid',
  },

  gui_mode = 'all', -- todo: remove
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
