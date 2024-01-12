local mod_prefix = 'fietff-'
local mod_path = '__factoryplanner-is-exportable-to-fake-factorissimo__'

local container_template = {
  type = 'container',

  icon = string.format(mod_path .. '/graphics/icon/factory-%d.png', config.i),

  enable_inventory_bar = false,

  flags = {
    'placeable-player',
    'player-creation',
    'hide-alt-info',
  },
  
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

local container_1 = table.deepcopy(container_template)
container_1.name = mod_prefix .. 'container-1'
container_1.icon = mod_path .. '/graphics/icon/factory-1.png'
container_1.collision_box = {{-3.8, -3.8}, {3.8, 3.8}}
container_1.selection_box = {{-3.8, -3.8}, {3.8, 3.8}}
container_1.inventory_size = 10 * 1
container_1.minable = {mining_time = 0.5 * 1,

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
