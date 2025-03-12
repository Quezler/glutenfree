require("util")

local Hurricane = {}

function Hurricane.assembling_machine(directory, name)
  local prefix = string.format("%s/%s/%s", directory, name, name)
  local config = require(prefix .. ".lua")
  local prefix = string.format("%s/%s/%s", directory, name .. config.directory_suffix, name)

  config.columns = config.columns or math.min(8, config.frames)
  config.rows = config.rows or math.min(8, math.ceil(config.frames / config.columns))

  local total_rows = math.ceil(config.frames / config.columns)
  local total_stripes = math.ceil(total_rows / config.rows)

  local frame_width = config.animation.width / config.columns
  local frame_height = config.animation.height / config.rows

  local function get_stripes(s)
    local stripes = {}

    for i = 1, total_stripes do
      stripes[i] = {
        filename = string.format(s, i),
        width_in_frames = config.columns,
        height_in_frames = math.min(config.rows, total_rows - (config.rows * (i - 1))),
      }
    end

    return stripes
  end

  local dimensions = util.split(config.size, "x")
  local half_x = dimensions[1] / 2
  local half_y = dimensions[2] / 2

  local to_return = {
    name = name,
    localised_name = config.localised_name,
    icon = config.icon_missing and  "__core__/graphics/icons/unknown.png" or prefix .. "-icon.png",

    selection_box = {{-half_x, -half_y}, {half_x, half_y}},
    collision_box = {{-half_x - 0.2, -half_y - 0.2}, {half_x - 0.2, half_y - 0.2}},

    graphics_set = {
      animation =
      {
        layers =
        {
          {
            priority = "high",
            width = frame_width,
            height = frame_height,
            frame_count = config.frames,
            animation_speed = 1,
            scale = 0.5,
            stripes = get_stripes(prefix .. "-hr-animation-%d.png"),
            shift = config.shift,
          },
          {
            filename = prefix .. "-hr-shadow.png",
            priority = "high",
            width = config.shadow.width,
            height = config.shadow.height,
            frame_count = 1,
            repeat_count = config.frames,
            draw_as_shadow = true,
            scale = 0.5,
            shift = config.shift,
          }
        }
      },
      working_visualisations = {},
    }
  }

  if config.emissions == 1 then
    table.insert(to_return.graphics_set.working_visualisations, {
      fadeout = true,
      animation = {
        priority = "high",
        width = frame_width,
        height = frame_height,
        frame_count = config.frames,
        animation_speed = 1,
        scale = 0.5,
        draw_as_glow = true,
        blend_mode = "additive",
        stripes = get_stripes(prefix .. "-hr-emission-%d.png"),
        shift = config.shift,
      }
    })
  elseif config.emissions > 1 then
    for i = 1, config.emissions do
      table.insert(to_return.graphics_set.working_visualisations, {
        fadeout = true,
        animation = {
          priority = "high",
          width = frame_width,
          height = frame_height,
          frame_count = config.frames,
          animation_speed = 1,
          scale = 0.5,
          draw_as_glow = true,
          blend_mode = "additive",
          stripes = get_stripes(prefix .. string.format("-hr-emission%d-%%d.png", i)),
          shift = config.shift,
        }
      })
    end
  end

  return to_return
end

return Hurricane
