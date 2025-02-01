-- written by Quezler to help himself and other modders to quickly get started with Hurricane's awesome sprite packs,
-- this file comes with no waranty, there's a chance you might need to tweak it, but it should get you started at least.

local Hurricane = {}

function Hurricane.crafter(config)
  local total_rows = math.ceil(config.total_frames / config.columns)
  local total_stripes = math.ceil(total_rows / config.rows)

  local function get_stripes(s)
    local stripes = {}

    for i = 1, total_stripes do
      stripes[i] = {
        filename = string.format(s, i),
        width_in_frames = config.columns,
        height_in_frames = math.min(8, total_rows - (8 * (i - 1))),
      }
    end

    return stripes
  end

  local graphics_set = {
    animation =
    {
      layers =
      {
        {
          priority = "high",
          width = config.width / config.columns,
          height = config.height / config.rows,
          frame_count = config.total_frames,
          animation_speed = 0.5,
          scale = 0.5,
          -- stripes = {
            -- {
            --   filename = mod_directory .. string.format("/graphics/%s/%s-hr-animation-1.png", config.name, config.name),
            --   width_in_frames = config.columns,
            --   height_in_frames = math.min(8, total_rows - (8 * 0)),
            -- },
          --   {
          --     filename = mod_directory .. string.format("/graphics/%s/%s-hr-animation-2.png", config.name, config.name),
          --     width_in_frames = config.columns,
          --     height_in_frames = math.min(8, total_rows - (8 * 1)),
          --   },
          -- },
          stripes = get_stripes(mod_directory .. string.format("/graphics/%s/%s-hr-animation-%%d.png", config.name, config.name))
        },
        {
          filename = mod_directory .. string.format("/graphics/%s/%s-hr-shadow.png", config.name, config.name),
          priority = "high",
          width = config.shadow_width,
          height = config.shadow_height,
          frame_count = 1,
          repeat_count = config.total_frames,
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
          width = config.width / config.columns,
          height = config.height / config.rows,
          frame_count = 80,
          animation_speed = 0.5,
          scale = 0.5,
          draw_as_glow = true,
          blend_mode = "additive",
          -- stripes =
          -- {
          --   {
          --     filename = mod_directory .. string.format("/graphics/%s/%s-hr-emission-1.png", config.name, config.name),
          --     width_in_frames = config.columns,
          --     height_in_frames = math.min(8, total_rows - (8 * 0)),
          --   },
          --   {
          --     filename = mod_directory .. string.format("/graphics/%s/%s-hr-emission-2.png", config.name, config.name),
          --     width_in_frames = config.columns,
          --     height_in_frames = math.min(8, total_rows - (8 * 1)),
          --   },
          -- },
          stripes = get_stripes(mod_directory .. string.format("/graphics/%s/%s-hr-emission-%%d.png", config.name, config.name))
        },
      },
    },
  }

  return {
    icon = mod_directory .. string.format("/graphics/%s/%s-icon.png", config.name, config.name),
    graphics_set = graphics_set,
  }
end

return Hurricane
