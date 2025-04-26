local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

require("util")

local storage_tank = {
  type = "storage-tank",
  name = "pipe-pillar",
  icon = mod_directory .. "/graphics/icons/pipe-pillar.png",
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.25, result = "pipe-pillar"},
  max_health = 250,
  -- corpse = "storage-tank-remnants",
  -- dying_explosion = "storage-tank-explosion",
  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
  fast_replaceable_group = "pipe",
  damaged_trigger_effect = hit_effects.entity(),
  drawing_box_vertical_extension = 3.5,
  icon_draw_specification = {scale = 0.75, shift = {0, -3.8}},
  fluid_box =
  {
    volume = 500,
    pipe_connections =
    {
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
      {
        connection_type = "linked",
        linked_connection_id = 0,
      },
    },
    hide_connection_info = true
  },
  two_direction_only = true,
  window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
  pictures =
  {
    picture =
    {
      sheets =
      {
        {
          filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar.png",
          priority = "extra-high",
          frames = 1,
          width = 704,
          height = 704,
          scale = 0.5
        },
        {
          filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-shadow.png",
          priority = "extra-high",
          frames = 1,
          width = 704,
          height = 704,
          scale = 0.5,
          draw_as_shadow = true
        }
      }
    },
    -- fluid_background =
    -- {
    --   filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
    --   priority = "extra-high",
    --   width = 32,
    --   height = 15
    -- },
    -- window_background =
    -- {
    --   filename = "__base__/graphics/entity/storage-tank/window-background.png",
    --   priority = "extra-high",
    --   width = 34,
    --   height = 48,
    --   scale = 0.5
    -- },
    -- flow_sprite =
    -- {
    --   filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
    --   priority = "extra-high",
    --   width = 160,
    --   height = 20
    -- },
    -- gas_flow =
    -- {
    --   filename = "__base__/graphics/entity/pipe/steam.png",
    --   priority = "extra-high",
    --   line_length = 10,
    --   width = 48,
    --   height = 30,
    --   frame_count = 60,
    --   animation_speed = 0.25,
    --   scale = 0.5
    -- }
  },
  flow_length_in_ticks = 360,
  impact_category = "metal-large",
  open_sound = sounds.metal_large_open,
  close_sound = sounds.metal_large_close,
  working_sound =
  {
    sound = {filename = "__base__/sound/storage-tank.ogg", volume = 0.6, audible_distance_modifier = 0.5},
    match_volume_to_activity = true,
    max_sounds_per_prototype = 3
  },

  circuit_connector = circuit_connector_definitions["storage-tank"],
  circuit_wire_max_distance = default_circuit_wire_max_distance,
  water_reflection =
  {
    pictures =
    {
      filename = "__base__/graphics/entity/storage-tank/storage-tank-reflection.png",
      priority = "extra-high",
      width = 24,
      height = 24,
      shift = util.by_pixel(5, 35),
      variation_count = 1,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = false
  }
}

local recipe_category = {
  type = "recipe-category",
  name = "pipe-pillar",
}

local furnace = {
  type = "furnace",
  name = "pipe-pillar-pipe-connection",

  collision_mask = {layers = {}},
  collision_box = storage_tank.collision_box,
  selection_box = storage_tank.selection_box,
  selection_priority = 49,
  flags = {"not-on-map"},

  energy_usage = "1kW",
  energy_source = {type = "void"},
  crafting_speed = 1,
  crafting_categories = {"pipe-pillar"},

  source_inventory_size = 0,
  result_inventory_size = 0,

  fluid_boxes =
  {{
    volume = 1,
    pipe_connections =
    {
      {
        connection_type = "linked",
        linked_connection_id = 0,
      },
      { direction = defines.direction.north, position = {0, 0}, enable_working_visualisations = { "pipe-connection", "occluder-bottom" } },
      { direction = defines.direction.east , position = {0, 0}, enable_working_visualisations = { "pipe-connection", "occluder-bottom" } },
      { direction = defines.direction.south, position = {0, 0}, enable_working_visualisations = { "pipe-connection", "occluder-bottom" } },
      { direction = defines.direction.west , position = {0, 0}, enable_working_visualisations = { "pipe-connection", "occluder-bottom" } },
    },
    hide_connection_info = true,
    production_type = "input",
    draw_only_when_connected = true,
    always_draw_covers = false,
  }},

  graphics_set = {
    working_visualisations =
    {

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
              scale = 0.5
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
      -- {
      --   always_draw = true,
      --   name = "pipe-covers",
      --   enabled_by_name = true,
      --   render_layer = "object-under",
      --   animation = {
      --     layers = {
      --       {
      --         filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-bottom-pipe-left.png",
      --         width = 704,
      --         height = 704,
      --         scale = 0.5
      --       },
      --       {
      --         filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-bottom-pipe-right.png",
      --         width = 704,
      --         height = 704,
      --         scale = 0.5
      --       },
      --     }
      --   },
      -- },
      {
        always_draw = true,
        name = "occluder-bottom",
        enabled_by_name = true,
        render_layer = "cargo-hatch",
        animation = {
          layers = {
            {
              filename = mod_directory .. "/graphics/entity/pipe-pillar/pipe-pillar-occluder-bottom.png",
              width = 704,
              height = 704,
              scale = 0.5
            },
          }
        },
      },

    },
  }
}

data:extend{storage_tank, recipe_category, furnace}
