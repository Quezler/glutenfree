local power_switch = {
  type = "power-switch",
  name = "thruster-control-behavior",
  icon = "__thruster-control-behavior__/graphics/icons/thruster-control-behavior.png",

  overlay_start_delay = 0,

  circuit_wire_connection_point =
  {
    shadow =
    {
      red   = util.by_pixel(-14, 34+3),
      green = util.by_pixel(-22, 34+3)
    },
    wire =
    {
      red =   util.by_pixel(-17, 26+3),
      green = util.by_pixel(-24, 26+3)
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
