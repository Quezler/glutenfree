local Hurricane = {}

function Hurricane.crafter(config)
  local prefix = mod_directory .. string.format("/graphics/%s/%s-", config.name , config.name)

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
          animation_speed = 1,
          scale = 0.5,
          stripes = get_stripes(prefix .. "hr-animation-%d.png")
        },
        {
          filename = prefix .. "hr-shadow.png",
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
          frame_count = config.total_frames,
          animation_speed = 1,
          scale = 0.5,
          draw_as_glow = true,
          blend_mode = "additive",
          stripes = get_stripes(prefix .. "hr-emission-%d.png")
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
      icon = prefix .. "icon-big.png",
      icon_size = 320,
      scale = 0.19 * 2, -- 256 / 2 / 320 = 0.4
    },
  }

  return {
    icon = prefix .. "icon.png",
    graphics_set = graphics_set,
    technology_icons = technology_icons,
  }
end

return Hurricane
