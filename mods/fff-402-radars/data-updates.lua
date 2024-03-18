local mod_prefix = 'fff-402-radars-'
local corner_to_center = 1500000 -- 1.5 million, with like 0.1 of wiggle room

local circuit_connector_definition = circuit_connector_definitions.create(universal_connector_template,
  {{variation = 24, main_offset = util.by_pixel(-42.5, -10), shadow_offset = util.by_pixel(-42, -7.5), show_shadow = false}}
)

local radar = data.raw['radar']['radar']
local w_pole = data.raw['item']['small-electric-pole']
local r_wire = data.raw['item']['red-wire']

data:extend{{
  type = 'container',
  name = mod_prefix .. 'circuit-relay',

  selectable_in_game = false,
  selection_box = radar.selection_box,
  collision_box = radar.collision_box,
  collision_mask = {},

  inventory_size = 0,
  picture = util.empty_sprite(),

  circuit_wire_max_distance = corner_to_center,
  draw_circuit_wires = false,

  icons = {
    {icon = radar.icon, icon_size = radar.icon_size, icon_mipmaps = radar.icon_mipmaps},
    {icon = w_pole.icon, icon_size = w_pole.icon_size, icon_mipmaps = w_pole.icon_mipmaps, scale = 0.5},
  },

  flags = {"no-automated-item-removal", "no-automated-item-insertion", "not-on-map"},
}}

data:extend{{
  type = 'container',
  name = mod_prefix .. 'circuit-connector',

  selection_priority = 51,
  selection_box = {{-1.5, -1.5}, {0, 1.5}},
  collision_box = radar.collision_box,
  collision_mask = {},

  inventory_size = 0,
  picture = util.empty_sprite(),

  circuit_wire_max_distance = corner_to_center,
  circuit_wire_connection_point = circuit_connector_definition.points,
  circuit_connector_sprites = circuit_connector_definition.sprites,

  icons = {
    {icon = radar.icon, icon_size = radar.icon_size, icon_mipmaps = radar.icon_mipmaps},
    {icon = r_wire.icon, icon_size = r_wire.icon_size, icon_mipmaps = r_wire.icon_mipmaps, scale = 0.5},
  },

  flags = {"player-creation", "no-automated-item-removal", "no-automated-item-insertion", "not-on-map"},
}}

data:extend{{
  type = 'item',
  name = mod_prefix .. 'circuit-connector',

  stack_size = 1,
  icons = data.raw['container'][mod_prefix .. 'circuit-connector'].icons,
  flags = {"hidden"},
  place_result = mod_prefix .. 'circuit-connector',
}}
