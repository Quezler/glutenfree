require("util")

local power_switch = {
  type = "power-switch",
  name = "thruster-control-behavior",
  icon = "__thruster-control-behavior__/graphics/icons/thruster-control-behavior.png",

  overlay_start_delay = 0,
  wire_max_distance = default_circuit_wire_max_distance,

  circuit_wire_connection_point =
  {
    shadow =
    {
      red   = util.by_pixel(-9,  1),    -- a guess
      green = util.by_pixel(-9,  1 - 4) -- a guess
    },
    wire =
    {
      red   = util.by_pixel(-9, -1),
      green = util.by_pixel(-9, -1 - 4)
    }
  },

  left_wire_connection_point =
  {
    shadow =
    {
      copper = util.by_pixel(0, 0)
    },
    wire =
    {
      copper = util.by_pixel(0, 0)
    }
  },

  right_wire_connection_point =
  {
    shadow =
    {
      copper = util.by_pixel(0, 0)
    },
    wire =
    {
      copper = util.by_pixel(0, 0)
    }
  },

  power_on_animation =
  {
    layers = {
      {
        filename = "__thruster-control-behavior__/graphics/entity/thruster-control-behavior.png",
        animation_speed = 1,
        line_length = 0,
        width = 12,
        height = 21,
        frame_count = 1,
        shift = util.by_pixel(-9, -3),
        scale = 0.4
      },
    }
  },

  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  collision_mask = {layers = {}},
  selection_priority = 51,

  flags = {"player-creation"},
  hidden = true,
}

local power_switch_item = {
  type = "item",
  name = "thruster-control-behavior",
  icon = "__thruster-control-behavior__/graphics/icons/thruster-control-behavior.png",

  stack_size = 10,
  place_result = power_switch.name,

  hidden = true,
}

data:extend{power_switch, power_switch_item}