
local mod_directory = "__energy-condenser-quality-edition__"

local graphics_set = {
  animation =
  {
    layers =
    {
      {
        priority = "high",
        width = 590,
        height = 590,
        frame_count = 1,
        animation_speed = 0.5,
        scale = 0.5,
        stripes = {
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-animation-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-animation-2.png",
            width_in_frames = 8,
            height_in_frames = 2,
          },
        },
      },
      {
        filename = mod_directory .. "/graphics/disruptor/disruptor-hr-shadow.png",
        priority = "high",
        width = 1200,
        height = 700,
        draw_as_shadow = true,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      }
    }
  },
  working_visualisations =
  {
    {
      fadeout = true,
      effect = "flicker",
      animation =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/stone-furnace/stone-furnace-fire.png",
            priority = "extra-high",
            line_length = 8,
            width = 41,
            height = 100,
            frame_count = 48,
            draw_as_glow = true,
            shift = util.by_pixel(-0.75, 5.5),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/stone-furnace/stone-furnace-light.png",
            blend_mode = "additive",
            width = 106,
            height = 144,
            repeat_count = 48,
            draw_as_glow = true,
            shift = util.by_pixel(0, 5),
            scale = 0.5,
          },
        }
      }
    },
    {
      fadeout = true,
      effect = "flicker",
      animation =
      {
        filename = "__base__/graphics/entity/stone-furnace/stone-furnace-ground-light.png",
        blend_mode = "additive",
        width = 116,
        height = 110,
        repeat_count = 48,
        draw_as_light = true,
        shift = util.by_pixel(-1, 44),
        scale = 0.5,
      },
    },
  },
  water_reflection =
  {
    pictures =
    {
      filename = "__base__/graphics/entity/stone-furnace/stone-furnace-reflection.png",
      priority = "extra-high",
      width = 16,
      height = 16,
      shift = util.by_pixel(0, 35),
      variation_count = 1,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = false
  }
}

return {graphics_set = graphics_set}
