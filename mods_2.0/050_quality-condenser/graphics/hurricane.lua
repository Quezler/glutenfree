local Hurricane = {}

function Hurricane.crafter(config)
  config.rows = config.rows or 8
  config.columns = config.columns or 8

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
          shift = config.shift,
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
          shift = config.shift,
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
          frame_count = config.total_frames,
          animation_speed = 0.5,
          scale = 0.5,
          shift = config.shift,
          draw_as_glow = true,
          blend_mode = "additive",
          stripes = get_stripes(mod_directory .. string.format("/graphics/%s/%s-hr-emission-%%d.png", config.name, config.name))
        },
      },
    },
  }

  local technology_icons = {
    {
      icon = "__core__/graphics/empty.png",
      icon_size = 1,
    },
    {
      icon = mod_directory .. string.format("/graphics/%s/%s-icon-big.png", config.name , config.name),
      icon_size = 640,
      scale = 0.19, -- 256 / 2 / 640 = 0.2
    },
  }

  return {
    icon = mod_directory .. string.format("/graphics/%s/%s-icon.png", config.name, config.name),
    graphics_set = graphics_set,
    technology_icons = technology_icons,
  }
end

return Hurricane
