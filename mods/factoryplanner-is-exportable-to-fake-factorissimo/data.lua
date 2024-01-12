local mod_prefix = 'fietff-'
local mod_path = '__factoryplanner-is-exportable-to-fake-factorissimo__'

local container = {
  type = 'container',
  name = mod_prefix .. 'container-1',

  icon = mod_path .. '/graphics/icon/factory-1.png',
  icon_size = 64,

  collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
  selection_box = {{-3.8, -3.8}, {3.8, 3.8}},

  inventory_size = 10,
  enable_inventory_bar = false,

  flags = {
    'placeable-player',
    'player-creation',
    'hide-alt-info',
  },

  minable = {mining_time = 0.2},
  
  picture = {
    layers = {
      {
        filename = mod_path .. '/graphics/factory/factory-1-shadow.png',
        width = 416,
        height = 320,
        shift = {1.5, 0},
        draw_as_shadow = true
      },
      {
        filename = mod_path .. '/graphics/factory/factory-1.png',
        width = 416,
        height = 320,
        shift = {1.5, 0},
      }
    }
  }
}

data:extend{container}
