local flib_bounding_box = require("__flib__/bounding-box")

local handbreak = {
  type = 'constant-combinator',
  name = 'se-spaceship-handbreak',
  item_slot_count = 1,

  sprites = {
    north = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/green.png',
      size = 256,
      scale = 0.5,
      shift = util.by_pixel(0, -16+3-1),
    },
    east = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/red.png',
      size = 256,
      scale = 0.5,
      shift = util.by_pixel(0, -16+3-1),
    },
    south = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/green.png',
      size = 256,
      scale = 0.5,
      shift = util.by_pixel(0, -16+3-1),
    },
    west = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/red.png',
      size = 256,
      scale = 0.5,
      shift = util.by_pixel(0, -16+3-1),
    }
  },

  activity_led_sprites = {
    north = util.empty_sprite(),
    east = util.empty_sprite(),
    south = util.empty_sprite(),
    west = util.empty_sprite(),
  },

  activity_led_light =
  {
    intensity = 0.0,
    size = 0,
  },

  activity_led_light_offsets = table.deepcopy(data.raw['constant-combinator']['constant-combinator'].activity_led_light_offsets),
  circuit_wire_connection_points = table.deepcopy(data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points),

  selection_box = flib_bounding_box.move({{-0.24, -0.24}, {0.24, 0.24}}, {0.45, 0.475}), -- flib not broken, test save was already rotated once
  drawing_box = {{-2, -2}, {2, 2}},

  selection_priority = 51,
  collision_mask = {},

  flags = {'placeable-neutral', 'placeable-off-grid'},
  icons = data.raw['accumulator']['se-spaceship-console'].icons,
}

data:extend({handbreak})
