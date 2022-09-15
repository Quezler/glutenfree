flib = require('__flib__.data-util')

local speaker = data.raw['programmable-speaker']['programmable-speaker']

-- local ltn_stop_announcer = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
-- ltn_stop_announcer.name = 'logistic-train-stop-announcer'
-- ltn_stop_announcer.icon = speaker.icon
-- ltn_stop_announcer.icon_size = 64
-- ltn_stop_announcer.icon_mipmaps = nil
-- ltn_stop_announcer.next_upgrade = nil
-- ltn_stop_announcer.minable = nil
-- ltn_stop_announcer.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
-- ltn_stop_announcer.selection_priority = (ltn_stop_announcer.selection_priority or 50) + 10
-- ltn_stop_announcer.collision_mask = {{-0.15, -0.15}, {0.15, 0.15}}
-- ltn_stop_announcer.collision_mask = {'rail-layer'}
-- ltn_stop_announcer.item_slot_count = 100
-- ltn_stop_announcer.sprites = speaker.sprite

local ltn_stop_announcer = {
  name = 'logistic-train-stop-announcer',
  type = 'electric-pole',
}

-- ltn_stop_announcer.pictures = make_4way_animation_from_spritesheet(speaker.sprite)
-- print(serpent.block(ltn_stop_announcer.pictures))
-- print('owo!')

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

-- ltn_stop_announcer.connection_points = {
--   connection_points,
--   -- connection_points,
--   -- connection_points,
--   -- connection_points,
-- }

ltn_stop_announcer.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
ltn_stop_announcer.selection_priority = (ltn_stop_announcer.selection_priority or 50) + 10
ltn_stop_announcer.collision_mask = {{-0.15, -0.15}, {0.15, 0.15}}
ltn_stop_announcer.collision_mask = {'rail-layer'}

ltn_stop_announcer.maximum_wire_distance = speaker.circuit_wire_max_distance
ltn_stop_announcer.draw_copper_wires = false

-- local ltn_stop_announcer = flib.copy_prototype(data.raw["constant-combinator"]["constant-combinator"], "logistic-train-stop-announcer")
-- ltn_stop_out.icon = "__LogisticTrainNetwork__/graphics/icons/output.png"
-- ltn_stop_out.icon = data.raw["constant-combinator"]"__LogisticTrainNetwork__/graphics/icons/output.png"
-- ltn_stop_out.icon_size = 64
-- ltn_stop_out.icon_mipmaps = nil
-- ltn_stop_out.next_upgrade = nil
-- ltn_stop_out.minable = nil
-- ltn_stop_out.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
-- ltn_stop_out.selection_priority = (ltn_stop_out.selection_priority or 50) + 10 -- increase priority to default + 10
-- ltn_stop_out.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
-- ltn_stop_out.collision_mask = {"rail-layer"} -- collide only with rail entities
-- ltn_stop_out.item_slot_count = 50


-- local ltn_stop_announcer_red = table.deepcopy(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'logistic-train-stop-announcer-red-signal')
-- ltn_stop_announcer_red.name = 'logistic-train-stop-announcer-red-signal'

local red_signal = flib.copy_prototype(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'logistic-train-stop-announcer-red-signal')
local green_signal = flib.copy_prototype(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'logistic-train-stop-announcer-green-signal')

red_signal.draw_circuit_wires = false
green_signal.draw_circuit_wires = false

data:extend({ltn_stop_announcer, red_signal, green_signal})
