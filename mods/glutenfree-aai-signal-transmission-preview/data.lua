local util = require('util')

local laptop = {}

laptop.name = 'glutenfree-aai-signal-transmission-preview-laptop'
laptop.type = 'electric-pole'
laptop.supply_area_distance = 0

local connection_points = {
  copper = util.by_pixel(0, 0),
  red = util.by_pixel(-9, 8),
  green = util.by_pixel(-7, 10),
}
laptop.connection_points = {{
  shadow = connection_points,
  wire = connection_points,
}}

laptop.pictures = util.empty_sprite()
laptop.pictures.filename = '__glutenfree-aai-signal-transmission-preview__/graphics/entity/laptop.png'
laptop.pictures.width = 84
laptop.pictures.height = 73
laptop.pictures.scale = 0.4

laptop.flags = {'placeable-off-grid'}
laptop.collision_mask = {}

laptop.selection_box = {{-0.4, -0.4}, {0.4, 0.4}}
laptop.maximum_wire_distance = 10

laptop.selection_priority = 51

data:extend({laptop})
