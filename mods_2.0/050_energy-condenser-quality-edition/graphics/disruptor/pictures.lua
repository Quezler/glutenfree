
local mod_directory = "__energy-condenser-quality-edition__"

local graphics_set = {
  animation =
  {
    layers =
    {
      {
        filename = mod_directory .. "/graphics/disruptor/disruptor-hr-animation-bg.png",
        priority = "high",
        width = 590,
        height = 590,
        frame_count = 1,
        repeat_count = 80,
        scale = 0.5,
      },
      {
        priority = "high",
        width = 590,
        height = 590,
        frame_count = 80,
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
        frame_count = 1,
        repeat_count = 80,
        draw_as_shadow = true,
        scale = 0.5,
      }
    }
  },
  working_visualisations =
  {
    {
      fadeout = true,
      animation = {
        priority = "high",
        width = 590,
        height = 590,
        frame_count = 80,
        animation_speed = 0.5,
        scale = 0.5,
        -- draw_as_light = true,
        blend_mode = "additive",
        stripes =
        {
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-emission-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-emission-2.png",
            width_in_frames = 8,
            height_in_frames = 2,
          },
        },
      },
    },
    {
      fadeout = true,
      animation = {
        priority = "high",
        width = 590,
        height = 590,
        frame_count = 80,
        animation_speed = 0.5,
        scale = 0.5,
        draw_as_light = true, -- only difference
        blend_mode = "additive",
        stripes =
        {
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-emission-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/disruptor/disruptor-hr-emission-2.png",
            width_in_frames = 8,
            height_in_frames = 2,
          },
        },
      },
    },
  },
}

return {graphics_set = graphics_set}
