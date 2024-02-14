local slingshot = {
  type = 'constant-combinator',
  name = 'se-spaceship-slingshot',

  item_slot_count = 1,

  sprites = {
    north = util.empty_sprite(),
    east = util.empty_sprite(),
    south = util.empty_sprite(),
    west = util.empty_sprite(),
  },

  activity_led_sprites = {
    north = util.empty_sprite(),
    east = util.empty_sprite(),
    south = util.empty_sprite(),
    west = util.empty_sprite(),
  },

  activity_led_light =
  {
    intensity = 0,
    size = 0,
  },

  activity_led_light_offsets = table.deepcopy(data.raw['constant-combinator']['constant-combinator'].activity_led_light_offsets),
  circuit_wire_connection_points = table.deepcopy(data.raw['constant-combinator']['constant-combinator'].circuit_wire_connection_points),
  circuit_wire_max_distance = data.raw['constant-combinator']['constant-combinator'].circuit_wire_max_distance,
  draw_circuit_wires = false,

  selection_box = {{-0.25, -0.25}, {0.25, 0.25}},
  -- selectable_in_game = false,

  selection_priority = 51,
  collision_mask = {},

  flags = {'placeable-neutral'},
  icons = data.raw['accumulator']['se-spaceship-console'].icons,
}

data:extend({slingshot})
