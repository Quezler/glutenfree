local function make_visualization(i)
  return
  {
    filename = "__Moshine__/graphics/entity/opticalfiber/visualization.png",
    priority = "extra-high",
    x = i * 64,
    size = 64,
    scale = 0.5,
    flags = {"icon"},
  }
end

local function make_disabled_visualization(i)
  return
  {
    filename = "__Moshine__/graphics/entity/opticalfiber/disabled-visualization.png",
    priority = "extra-high",
    x = i * 64,
    size = 64,
    scale = 0.5,
    flags = {"icon"},
  }
end

opticalfiberpictures = function()
  return
  {
    straight_vertical_single =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-straight-vertical-single.png",
      priority = "extra-high",
      width = 160,
      height = 160,
      scale = 0.5
    },
    straight_vertical =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-straight-vertical.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_vertical_window =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-straight-vertical.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_horizontal_window =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-straight-horizontal.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_horizontal =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-straight-horizontal.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_up_right =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-corner-up-right.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_up_left =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-corner-up-left.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_down_right =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-corner-down-right.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    corner_down_left =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-corner-down-left.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_up =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-t-up.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_down =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-t-down.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_right =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-t-right.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    t_left =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-t-left.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    cross =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-cross.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_up =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-ending-up.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_down =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-ending-down.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_right =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-ending-right.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    ending_left =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-ending-left.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    straight_vertical_single_visualization = make_visualization(0),
    straight_vertical_visualization = make_visualization(5),
    straight_vertical_window_visualization = make_visualization(5),
    straight_horizontal_window_visualization = make_visualization(10),
    straight_horizontal_visualization = make_visualization(10),
    corner_up_right_visualization = make_visualization(3),
    corner_up_left_visualization = make_visualization(9),
    corner_down_right_visualization = make_visualization(6),
    corner_down_left_visualization = make_visualization(12),
    t_up_visualization = make_visualization(11),
    t_down_visualization = make_visualization(14),
    t_right_visualization = make_visualization(7),
    t_left_visualization = make_visualization(13),
    cross_visualization = make_visualization(15),
    ending_up_visualization = make_visualization(1),
    ending_down_visualization = make_visualization(4),
    ending_right_visualization = make_visualization(2),
    ending_left_visualization = make_visualization(8),
    straight_vertical_single_disabled_visualization = make_disabled_visualization(0),
    straight_vertical_disabled_visualization = make_disabled_visualization(5),
    straight_vertical_window_disabled_visualization = make_disabled_visualization(5),
    straight_horizontal_window_disabled_visualization = make_disabled_visualization(10),
    straight_horizontal_disabled_visualization = make_disabled_visualization(10),
    corner_up_right_disabled_visualization = make_disabled_visualization(3),
    corner_up_left_disabled_visualization = make_disabled_visualization(9),
    corner_down_right_disabled_visualization = make_disabled_visualization(6),
    corner_down_left_disabled_visualization = make_disabled_visualization(12),
    t_up_disabled_visualization = make_disabled_visualization(11),
    t_down_disabled_visualization = make_disabled_visualization(14),
    t_right_disabled_visualization = make_disabled_visualization(7),
    t_left_disabled_visualization = make_disabled_visualization(13),
    cross_disabled_visualization = make_disabled_visualization(15),
    ending_up_disabled_visualization = make_disabled_visualization(1),
    ending_down_disabled_visualization = make_disabled_visualization(4),
    ending_right_disabled_visualization = make_disabled_visualization(2),
    ending_left_disabled_visualization = make_disabled_visualization(8),
    horizontal_window_background =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-horizontal-window-background.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    vertical_window_background =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/opticalfiber-vertical-window-background.png",
      priority = "extra-high",
      width = 128,
      height = 128,
      scale = 0.5
    },
    fluid_background =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/fluid-background.png",
      priority = "extra-high",
      width = 64,
      height = 40,
      scale = 3.5
    },
    low_temperature_flow =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/fluid-flow-low-temperature.png",
      priority = "extra-high",
      width = 160,
      scale = 8.5,
      height = 18
    },
    middle_temperature_flow =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/fluid-flow-medium-temperature.png",
      priority = "extra-high",
      width = 160,
      scale = 8.5,
      height = 18
    },
    high_temperature_flow =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/fluid-flow-high-temperature.png",
      priority = "extra-high",
      width = 160,
      scale = 8.5,
      height = 18
    },
    gas_flow =
    {
      filename = "__Moshine__/graphics/entity/opticalfiber/steam.png",
      priority = "extra-high",
      scale = 0,
      line_length = 10,
      width = 48,
      height = 30,
      frame_count = 60
    }
  }
end

opticalfibercoverspictures = function()
  return
  {
    north =
    {
      layers =
      {
        {
          filename = "__Moshine__/graphics/entity/opticalfiber-covers/opticalfiber-cover-north.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    east =
    {
      layers =
      {
        {
          filename = "__Moshine__/graphics/entity/opticalfiber-covers/opticalfiber-cover-east.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    south =
    {
      layers =
      {
        {
          filename = "__Moshine__/graphics/entity/opticalfiber-covers/opticalfiber-cover-south.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    },
    west =
    {
      layers =
      {
        {
          filename = "__Moshine__/graphics/entity/opticalfiber-covers/opticalfiber-cover-west.png",
          priority = "extra-high",
          width = 128,
          height = 128,
          scale = 0.5
        },
      }
    }
  }
end
