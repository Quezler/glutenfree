local mod_prefix = "circuit-controlled-beacon-interface--"

local entity = table.deepcopy(data.raw["beacon"]["beacon-interface--beacon"])
entity.name = mod_prefix .. "beacon"

local item = table.deepcopy(data.raw["item"]["beacon-interface--beacon"])
item.name = mod_prefix .. "beacon"

entity.minable.result = item.name
item.place_result = entity.name

entity.icons[2].icon = "__base__/graphics/icons/constant-combinator.png"
item.icons[2].icon = "__base__/graphics/icons/constant-combinator.png"

entity.graphics_set.animation_list[1].animation.layers[1].filename = "__circuit-controlled-beacon-interface__/graphics/entity/circuit-controlled-beacon-interface/circuit-controlled-beacon-interface-bottom.png"

-- "close enough" copy paste from the MIT licenced "Thruster control behavior" mod by Quezler
local power_switch = {
  type = "power-switch",
  name = mod_prefix .. "beacon-control-behavior",
  icons = table.deepcopy(entity.icons),

  overlay_start_delay = 0,
  wire_max_distance = default_circuit_wire_max_distance,

  circuit_wire_connection_point =
  {
    shadow =
    {
      red   = util.by_pixel(13,  5),    -- a guess
      green = util.by_pixel(13,  5 - 4) -- a guess
    },
    wire =
    {
      red   = util.by_pixel(13, -7),
      green = util.by_pixel(13, -7 - 4)
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
        filename = "__circuit-controlled-beacon-interface__/graphics/entity/circuit-controlled-beacon-interface/circuit-controlled-beacon-interface-control-behavior.png",
        animation_speed = 1,
        line_length = 0,
        width = 12,
        height = 21,
        frame_count = 1,
        shift = util.by_pixel(13, -9),
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

data:extend{entity, item, power_switch}
