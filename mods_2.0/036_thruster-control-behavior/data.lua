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
  weight = assert(data.raw["item"]["thruster"].weight),
  place_result = power_switch.name,

  hidden = true,
}

data:extend{power_switch, power_switch_item}

local thruster = data.raw["thruster"]["thruster"]
thruster.additional_pastable_entities = thruster.additional_pastable_entities or {}
table.insert(thruster.additional_pastable_entities, "thruster")

data:extend{{
  type = "planet",
  name = "thruster-control-behavior",
  icon = "__thruster-control-behavior__/graphics/icons/thruster-control-behavior.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

data:extend({
  {
    type = "custom-input",
    name = "thruster-control-behavior-open-gui",
    key_sequence = "mouse-button-1",
    linked_game_control = "open-gui",
  }
})

power_switch.led_on = {
  filename = "__thruster-control-behavior__/graphics/entity/thruster-bckg-vent-green.png",
  width = 29,
  height = 29,
  scale = 0.5,
  shift = util.by_pixel(87.75, -32.75),
}

power_switch.led_off = {
  filename = "__thruster-control-behavior__/graphics/entity/thruster-bckg-vent-red.png",
  width = 29,
  height = 29,
  scale = 0.5,
  shift = util.by_pixel(87.75, -32.75),
}

power_switch.localised_name = {"entity-name.thruster-control-behavior", {"entity-name.thruster"}}

if mods["fusion-thruster"] then
  local fusion_power_switch = table.deepcopy(power_switch)
  fusion_power_switch.name = "fusion-thruster-control-behavior"
  fusion_power_switch.led_on = nil
  fusion_power_switch.led_off = nil
  data:extend{fusion_power_switch}

  local fusion_thruster = data.raw["thruster"]["fusion-thruster"]
  fusion_thruster.additional_pastable_entities = fusion_thruster.additional_pastable_entities or {}
  table.insert(fusion_thruster.additional_pastable_entities, "fusion-thruster")

  fusion_power_switch.localised_name = {"entity-name.thruster-control-behavior", {"entity-name.fusion-thruster"}}
end

if mods["ion-thruster"] then
  local ion_power_switch = table.deepcopy(power_switch)
  ion_power_switch.name = "ion-thruster-control-behavior"
  ion_power_switch.led_on = nil
  ion_power_switch.led_off = nil
  data:extend{ion_power_switch}

  local ion_thruster = data.raw["thruster"]["ion-thruster"]
  ion_thruster.additional_pastable_entities = ion_thruster.additional_pastable_entities or {}
  table.insert(ion_thruster.additional_pastable_entities, "ion-thruster")

  ion_power_switch.localised_name = {"entity-name.thruster-control-behavior", {"entity-name.ion-thruster"}}
end
