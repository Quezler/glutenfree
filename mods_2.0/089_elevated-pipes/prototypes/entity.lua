local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

require("util")

data:extend{{
  type = "recipe-category",
  name = "elevated-pipe",
}}

local collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
local selection_box = {{-0.7, -0.7}, {0.7, 0.7}}

elevated_pipes.new_furnace = function(config)
local furnace = {
  type = "furnace",
  name = config.name,
  icon = config.icon,

  heating_energy = feature_flags["freezing"] and settings.startup["elevated-pipes--freezes"].value and "200kW" or nil, -- underground pipe + 50
  energy_usage = "1kW",
  energy_source = {type = "void"},
  crafting_speed = 1,
  crafting_categories = {"elevated-pipe"},

  source_inventory_size = 0,
  result_inventory_size = 0,

  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.25, result = config.name},
  max_health = 250,
  corpse = config.name .. "-remnants",
  -- dying_explosion = "storage-tank-explosion",
  collision_box = collision_box,
  selection_box = selection_box,
  fast_replaceable_group = "pipe",
  damaged_trigger_effect = hit_effects.entity(),
  drawing_box_vertical_extension = 3,

  custom_tooltip_fields = {
    {
      name = {"description.maximum-length"},
      value = tostring(config.max_underground_distance),
      order = 99,
      show_in_tooltip = false,
    }
  },
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
        max_underground_distance = config.max_underground_distance,
        connection_category = config.name,
      },
      {
        connection_type = "underground",
        direction = defines.direction.east,
        position = {0, 0},
        max_underground_distance = config.max_underground_distance,
        connection_category = config.name,
      },
      {
        connection_type = "underground",
        direction = defines.direction.south,
        position = {0, 0},
        max_underground_distance = config.max_underground_distance,
        connection_category = config.name,
      },
      {
        connection_type = "underground",
        direction = defines.direction.west,
        position = {0, 0},
        max_underground_distance = config.max_underground_distance,
        connection_category = config.name,
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
          filename = config.graphics .. ".png",
          priority = "extra-high",
          frames = 1,
          width = 704,
          height = 704,
          scale = 0.5,
        },
        {
          filename = config.graphics .. "-shadow.png",
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
              filename = config.graphics .. "-back-left-leg.png",
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
              filename = config.graphics .. "-pipe-connection.png",
              width = 704,
              height = 704,
              scale = 0.5,
            },
            {
              filename = config.graphics .. "-pipe-connection-shadow.png",
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
              filename = config.graphics .. "-pipe-covers.png",
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
              filename = config.graphics .. "-occluder-bottom.png",
              width = 704,
              height = 704,
              scale = 0.5,
            },
          }
        },
      },
      {
        always_draw = true,
        render_layer = "elevated-rail-stone-path-lower",
        animation = {
          layers = {
            {
              filename = config.graphics .. "-occluder-top.png",
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

  bottleneck_ignore = true,
}

  if mods["maraxsis"] then
    local can_be_placed_anywhere = {water = true, dome = true, coral = true, trench = true, trench_entrance = true, trench_lava = true}
    furnace.maraxsis_buildability_rules = can_be_placed_anywhere
    data.raw["mod-data"]["maraxsis-constants"].data["DOME_EXCLUDED_FROM_DISABLE"][config.name] = true
  end

  if mods["actual-underground-pipes"] then
    furnace.ignore_by_tomwub = true
  end

  return furnace
end

elevated_pipes.new_storage_tank = function(config)
return {
  type = "storage-tank",
  name = config.name .. "-alt-mode",
  localised_name = {"entity-name." .. config.name},
  icon = config.icon,

  collision_mask = {layers = {}},
  collision_box = collision_box,
  selection_box = selection_box,
  selection_priority = 49,

  icon_draw_specification = {scale = 0.5, shift = {0, -3}},
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
end

elevated_pipes.new_corpse = function (config)
return {
  type = "corpse",
  name = config.name .. "-remnants",
  icon = config.icon,
  flags = {"placeable-neutral", "not-on-map"},
  hidden_in_factoriopedia = true,
  subgroup = "storage-remnants",
  order = "a-d-a",
  selection_box = selection_box,
  tile_width = 1,
  tile_height = 1,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutes
  expires = false,
  final_render_layer = "object",
  animation_overlay_final_render_layer = "object",
  remove_on_tile_placement = false,
  animation = {
    {
      filename = config.graphics .. "-remnant.png",
      line_length = 1,
      width = 704,
      height = 704,
      direction_count = 1,
      scale = 0.5,
    },
  },
  animation_overlay = {
    filename = config.graphics .. "-remnant-shadow.png",
    line_length = 1,
    width = 704,
    height = 704,
    direction_count = 1,
    scale = 0.5,
    tint = {1, 1, 1, 0.5},
  },
}
end

if mods["Bottleneck"] then
  data.raw["simple-entity-with-force"]["bottleneck-stoplight"].created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "script",
          effect_id = "bottleneck-stoplight-created",
        },
      }
    }
  }
end
