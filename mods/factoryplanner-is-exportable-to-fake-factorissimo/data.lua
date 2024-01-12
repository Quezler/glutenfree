local mod_prefix = 'fietff-'
local mod_path = '__factoryplanner-is-exportable-to-fake-factorissimo__'

local function create_container(config)
  return {
    type = 'container',
    name = mod_prefix .. 'container-' .. config.i,
  
    icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', config.i),
    icon_size = 64,
  
    collision_box = config.collision_box,
    selection_box = config.selection_box,
  
    inventory_size = 10 * config.i,
    enable_inventory_bar = false,
  
    flags = {
      'placeable-player',
      'player-creation',
      'hide-alt-info',
    },
  
    minable = {mining_time = 0.2 * config.i},
    
    picture = {
      layers = {
        {
          filename = string.format(mod_path .. '/graphics/factory/factory-%d-shadow.png', config.i),
          width = 416,
          height = 320,
          shift = config.shift,
          draw_as_shadow = true
        },
        {
          filename = string.format(mod_path .. '/graphics/factory/factory-1-alt.png', config.i),
          width = 416,
          height = 320,
          shift = config.shift,
        }
      }
    }
  }
end

local container_1 = create_container({
  i = 1,
  collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selection_box = {{-3.8, -3.8}, {3.8, 3.8}},
  layer_shift = {1.5, 0},
})

local container_2 = create_container({
  i = 2,
  collision_box = {{-5.8, -5.8}, {5.8, 5.8}},
  selection_box = {{-5.8, -5.8}, {5.8, 5.8}},
  layer_shift = {1.5, 0},
})

local container_3 = create_container({
  i = 3,
  collision_box = {{-7.8, -7.8}, {7.8, 7.8}},
  selection_box = {{-7.8, -7.8}, {7.8, 7.8}},
  layer_shift = {2, -0.09375},
})

data:extend{container}
