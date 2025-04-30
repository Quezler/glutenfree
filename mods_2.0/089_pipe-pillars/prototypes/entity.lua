local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

require("util")

local recipe_category = {
  type = "recipe-category",
  name = "pipe-pillar",
}

local furnace = {
  type = "furnace",
  name = "pipe-pillar",
  icon = mod_directory .. "/graphics/icons/pipe-pillar.png",

  energy_usage = "1kW",
  energy_source = {type = "void"},
  crafting_speed = 1,
  crafting_categories = {"pipe-pillar"},

  source_inventory_size = 0,
  result_inventory_size = 0,

  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.25, result = "pipe-pillar"},
  max_health = 250,
  corpse = "pipe-pillar-remnants",
  -- dying_explosion = "storage-tank-explosion",
  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
  fast_replaceable_group = "pipe",
  damaged_trigger_effect = hit_effects.entity(),
  drawing_box_vertical_extension = 3,
  fluid_boxes =
  {{
    volume = 1,
    pipe_connections =
    {
      {
        connection_type = "linked",
        linked_connection_id = 0,
      },
      {
        connection_type = "underground",
        direction = defines.direction.north,
        position = {0, 0},
        max_underground_distance = 10,
        connection_category = "pipe-pillar",
      },
      {
        connection_type = "underground",
        direction = defines.direction.east,
        position = {0, 0},
        max_underground_distance = 10,
        connection_category = "pipe-pillar",
      },
      {
        connection_type = "underground",
        direction = defines.direction.south,
        position = {0, 0},
        max_underground_distance = 10,
        connection_category = "pipe-pillar",
      },
      {
        connection_type = "underground",
        direction = defines.direction.west,
        position = {0, 0},
        max_underground_distance = 10,
        connection_category = "pipe-pillar",
      },
      { direction = defines.direction.north, position = {0, 0}, enable_working_visualisations = { "pipe-connection", "pipe-covers" }},
      { direction = defines.direction.east , position = {0, 0}, enable_working_visualisations = { "pipe-connection", "pipe-covers" }},
      { direction = defines.direction.south, position = {0, 0}, enable_working_visualisations = { "pipe-connection", "pipe-covers" }},
      { direction = defines.direction.west , position = {0, 0}, enable_working_visualisations = { "pipe-connection", "pipe-covers" }},
    },
    production_type = "input",
    draw_only_when_connected = true,
    hide_connection_info = true,
    always_draw_covers = true,
  }},

  graphics_set =
  {
    animation =
    {
      layers =
      {
        {
          filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar.png",
          priority = "extra-high",
          frames = 1,
          width = 704,
          height = 704,
          scale = 0.5,
        },
        {
          filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-shadow.png",
          priority = "extra-high",
          frames = 1,
          width = 704,
          height = 704,
          scale = 0.5,
          draw_as_shadow = true,
        }
      }
    },
    working_visualisations =
    {
      {
        always_draw = true,
        render_layer = "object-under",
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-back-left-leg.png",
              width = 704,
              height = 704,
              scale = 0.5
            },
          }
        },
      },
      {
        always_draw = true,
        name = "pipe-connection",
        enabled_by_name = true,
        secondary_draw_order = 1,
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-pipe-connection.png",
              width = 704,
              height = 704,
              scale = 0.5,
            },
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-pipe-connection-shadow.png",
              width = 704,
              height = 704,
              scale = 0.5,
              draw_as_shadow = true,
            },
          }
        },
      },
      {
        always_draw = true,
        name = "pipe-covers",
        enabled_by_name = true,
        render_layer = "object-under",
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-pipe-covers.png",
              width = 704,
              height = 704,
              scale = 0.5,
            }
          }
        },
      },
      {
        always_draw = true,
        render_layer = "cargo-hatch",
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-occluder-bottom.png",
              width = 704,
              height = 704,
              scale = 0.5,
            },
          }
        },
      },
      {
        always_draw = true,
        render_layer = "cargo-hatch",
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-occluder-top.png",
              width = 704,
              height = 704,
              scale = 0.5,
            },
          }
        },
      },
    }, -- working_visualisations
  },
  impact_category = "metal-large",
  open_sound = sounds.metal_large_open,
  close_sound = sounds.metal_large_close,

  -- circuit_connector = circuit_connector_definitions["storage-tank"],
  -- circuit_wire_max_distance = default_circuit_wire_max_distance,
}


local storage_tank = {
  type = "storage-tank",
  name = "pipe-pillar-alt-mode",
  icon = mod_directory .. "/graphics/icons/pipe-pillar.png",

  collision_mask = {layers = {}},
  collision_box = furnace.collision_box,
  selection_box = furnace.selection_box,
  selection_priority = 49,

  icon_draw_specification = {scale = 0.75, shift = {0, -3.25}},
  flags = {"not-on-map"},

  two_direction_only = true,
  window_bounding_box = {{0, 0}, {0, 0}},
  flow_length_in_ticks = 1,

  fluid_box =
  {
    volume = 1,
    pipe_connections =
    {
      {
        connection_type = "linked",
        linked_connection_id = 0,
      },
    },
  },
}

local corpse = {
  type = "corpse",
  name = "pipe-pillar-remnants",
  icon = furnace.icon,
  flags = {"placeable-neutral", "not-on-map"},
  hidden_in_factoriopedia = true,
  subgroup = "storage-remnants",
  order = "a-d-a",
  selection_box = furnace.selection_box,
  tile_width = 1,
  tile_height = 1,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  expires = false,
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  animation = make_rotated_animation_variations_from_sheet(1,
  {
    filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-remnant-2.png",
    line_length = 1,
    width = 704,
    height = 704,
    direction_count = 1,
    scale = 0.5
  })
}

data:extend{recipe_category, furnace, storage_tank, corpse}
