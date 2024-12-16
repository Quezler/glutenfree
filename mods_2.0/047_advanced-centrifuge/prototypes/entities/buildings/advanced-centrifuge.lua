local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")

local recipe_tint = "none"
local light_tint = {r = 0.0, g = 1.0, b = 0.0}

if mods["space-exploration"] then
  recipe_tint = "primary"
  light_tint = {r = 1.0, g = 1.0, b = 1.0}
end

data:extend({
  {
    type = "assembling-machine",
    name = "k11-advanced-centrifuge",
    icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon.png",
    flags = { "placeable-neutral", "placeable-player", "player-creation" },
    minable = { mining_time = 1, result = "k11-advanced-centrifuge" },
    max_health = 1000,
    corpse = "nuclear-reactor-remnants",
    dying_explosion = "big-explosion",
    resistances = {
      { type = "physical", percent = 40 },
      { type = "fire", percent = 60 },
      { type = "impact", percent = 60 },
    },
    collision_box = { { -3.25, -3.25 }, { 3.25, 3.25 } },
    selection_box = { { -3.5, -3.5 }, { 3.5, 3.5 } },
    fast_replaceable_group = "assembling-machine",
    circuit_wire_max_distance = data.raw["assembling-machine"]["centrifuge"].circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector(universal_connector_template, {
      { variation = 26, main_offset = util.by_pixel(0, -20.5), shadow_offset = util.by_pixel(0, -20.5), show_shadow = true },
      { variation = 26, main_offset = util.by_pixel(0, -20.5), shadow_offset = util.by_pixel(0, -20.5), show_shadow = true },
      { variation = 26, main_offset = util.by_pixel(0, -20.5), shadow_offset = util.by_pixel(0, -20.5), show_shadow = true },
      { variation = 26, main_offset = util.by_pixel(0, -20.5), shadow_offset = util.by_pixel(0, -20.5), show_shadow = true },
    }),

    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge.png",
            priority = "high",
            width = 450,
            height = 550,
            shift = { 0, -0.9 },
            frame_count = 30,
            line_length = 5,
            animation_speed = 0.125,
            scale = 0.5,
          },
          {
            filename = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-sh.png",
            priority = "high",
            width = 700,
            height = 550,
            shift = { 1.27, -0.38 },
            frame_count = 1,
            repeat_count = 30,
            animation_speed = 0.125,
            scale = 0.4422,
            draw_as_shadow = true,
          },
        },
      },
      working_visualisations = {
        {
          effect = "uranium-glow",
          fadeout = true,
          light = {intensity = 0.2, size = 9.9, shift = {0.0, 0.0}, color = {r = 1.0, g = 0.9, b = 0.9}}
        },
        {
          effect = "uranium-glow",
          fadeout = true,
          draw_as_light = true,
          apply_recipe_tint = recipe_tint,
          animation =
          {
            layers =
            {
              {
                filename = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-light.png",
                priority = "high",
                blend_mode = "additive", -- centrifuge
                tint = light_tint,
                line_length = 5,
                width = 450,
                height = 550,
                frame_count = 30,
                scale = 0.5,
                animation_speed = 0.125,
                shift = { 0, -0.9 }
              }
            }
          }
        }
      },
    },

    crafting_categories = { "centrifuging" },
    working_sound = {
      sound = {filename = "__advanced-centrifuge__/sounds/advanced-centrifuge.ogg" , volume = 2 },
      idle_sound = { filename = "__base__/sound/idle1.ogg" },
      apparent_volume = 8,
      fade_in_ticks = 20,
      fade_out_ticks = 20,
    },
    crafting_speed = 8,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 30 },
    },

    water_reflection = {
      pictures = {
        filename = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-reflection.png",
        priority = "extra-high",
        width = 225,
        height = 275,
        shift = { 0, 3 },
        variation_count = 1,
        scale = 0.8844,
      },
      rotate = false,
      orientation_to_variation = false,
    },

    energy_usage = "2.0MW",
    ingredient_count = 6,
    icon_draw_specification = {shift = {0, -1.25}, scale = 2},
    module_slots = 3,
    icons_positioning = {
      {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 1.7}, scale = 1}
    },
    allowed_effects = { "consumption", "speed", "productivity", "pollution", "quality" },
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    vehicle_impact_sound = sounds.generic_impact,
    damaged_trigger_effect = hit_effects.entity(),
  }
})

