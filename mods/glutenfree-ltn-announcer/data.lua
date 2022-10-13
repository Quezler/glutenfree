flib = require('__flib__.data-util')

local speaker = data.raw['programmable-speaker']['programmable-speaker']

--

local ltn_stop_announcer = {
  name = 'logistic-train-stop-announcer',
  type = 'electric-pole',
}

ltn_stop_announcer.pictures = speaker.sprite
ltn_stop_announcer.pictures.layers[1].direction_count = 1
ltn_stop_announcer.pictures.layers[1].hr_version.direction_count = 1
ltn_stop_announcer.pictures.layers[2].direction_count = 1
ltn_stop_announcer.pictures.layers[2].hr_version.direction_count = 1

ltn_stop_announcer.supply_area_distance = 0

local connection_points = {
  copper = util.by_pixel(0, -15),
  red = util.by_pixel(0, -15),
  green = util.by_pixel(0, -15),
}

ltn_stop_announcer.connection_points = {{
  shadow = connection_points,
  wire = connection_points,
}}

ltn_stop_announcer.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ltn_stop_announcer.selection_priority = (ltn_stop_announcer.selection_priority or 50) + 10
ltn_stop_announcer.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
ltn_stop_announcer.collision_mask = {'rail-layer'}

ltn_stop_announcer.maximum_wire_distance = speaker.circuit_wire_max_distance
ltn_stop_announcer.draw_copper_wires = false

ltn_stop_announcer.flags = {'player-creation'}
ltn_stop_announcer.placeable_by = {item = 'programmable-speaker', count = 1}

local red_signal = flib.copy_prototype(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'logistic-train-stop-announcer-red-signal')
local green_signal = flib.copy_prototype(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'logistic-train-stop-announcer-green-signal')

red_signal.draw_circuit_wires = false
green_signal.draw_circuit_wires = false

red_signal.item_slot_count = 100
green_signal.item_slot_count = 100

--

data:extend({ltn_stop_announcer, red_signal, green_signal})
