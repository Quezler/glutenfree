local entity = {
  type = "constant-combinator",
  name = "read-belt-contents-hold-all-belts-read-belt-count",
  icon = data.raw["virtual-signal"]["signal-B"].icon,

  selection_box = {{-0.2, -0.2}, {0.2, 0.2}},
  collision_box = data.raw["transport-belt"]["transport-belt"].collision_box,
  collision_mask = {layers = {}},

  activity_led_light_offsets = {{0, 0}, {0, 0}, {0, 0}, {0, 0}},
  circuit_wire_connection_points = data.raw["constant-combinator"]["constant-combinator"].circuit_wire_connection_points,
  draw_circuit_wires = false,

  flags = {"player-creation"},
  selection_priority = 51,
  selectable_in_game = false,

  hidden = true,
}

local item = {
  type = "item",
  name = "read-belt-contents-hold-all-belts-read-belt-count",
  icon = data.raw["virtual-signal"]["signal-B"].icon,

  stack_size = 1,
  flags = {"not-stackable"},
  place_result = "read-belt-contents-hold-all-belts-read-belt-count",

  hidden = true,
}

require("shared")

if debug_mode then
  entity.selectable_in_game = true
  entity.collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
end

data:extend{entity, item}
