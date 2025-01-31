local graphics_set = {
  animation =
  {
    layers =
    {
      {
        priority = "high",
        width = 4720 / 8,
        height = 5120 / 8,
        frame_count = 80,
        animation_speed = 0.5,
        scale = 0.5,
        stripes = {
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-animation-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-animation-2.png",
            width_in_frames = 8,
            height_in_frames = 2,
          },
        },
      },
      {
        filename = mod_directory .. "/graphics/research-center/research-center-hr-shadow.png",
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
        width = 4720 / 8,
        height = 5120 / 8,
        frame_count = 80,
        animation_speed = 0.5,
        scale = 0.5,
        draw_as_light = false, -- daytime
        blend_mode = "additive",
        stripes =
        {
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-emission-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-emission-2.png",
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
        width = 4720 / 8,
        height = 5120 / 8,
        frame_count = 80,
        animation_speed = 0.5,
        scale = 0.5,
        draw_as_light = true, -- nighttime
        blend_mode = "additive",
        stripes =
        {
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-emission-1.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = mod_directory .. "/graphics/research-center/research-center-hr-emission-2.png",
            width_in_frames = 8,
            height_in_frames = 2,
          },
        },
      },
    },
  },
}

return {graphics_set = graphics_set}
