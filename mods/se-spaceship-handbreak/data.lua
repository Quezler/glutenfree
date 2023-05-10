local handbreak = {
  type = 'constant-combinator',
  name = 'se-spaceship-handbreak',
  item_slot_count = 1,

  sprites = {
    north = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/green.png',
      size = 12,
      scale = 0.5,
      shift = util.by_pixel(0, -1),
      draw_as_glow = true,
    },
    east = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/red.png',
      size = 12,
      scale = 0.5,
      shift = util.by_pixel(0, -1),
      draw_as_glow = true,
    },
    south = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/green.png',
      size = 12,
      scale = 0.5,
      shift = util.by_pixel(0, -1),
      draw_as_glow = true,
    },
    west = {
      filename = '__se-spaceship-handbreak__/graphics/entity/se-spaceship-handbreak/red.png',
      size = 12,
      scale = 0.5,
      shift = util.by_pixel(0, -1),
      draw_as_glow = true,
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

  selection_box = {{-0.24, -0.24}, {0.24, 0.24}},
  drawing_box = {{-0.24, -0.24}, {0.24, 0.24}},

  selection_priority = 51,
  collision_mask = {},

  flags = {'placeable-neutral', 'placeable-off-grid'},
  icons = data.raw['accumulator']['se-spaceship-console'].icons,
}

handbreak.integration_patch = handbreak.sprites
handbreak.integration_patch_render_layer = 'higher-object-under'

data:extend({handbreak})
