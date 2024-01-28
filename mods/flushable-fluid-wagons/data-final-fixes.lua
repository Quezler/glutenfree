for _, prototype in pairs(data.raw['fluid-wagon']) do

  local tank = {
    type = 'storage-tank',
    name = prototype.name .. '-flushable',
    localised_name = {'entity-name.' .. prototype.name},

    fluid_box = {
      pipe_connections = {},
      base_area = prototype.capacity / 100,
    },

    window_bounding_box = {{0, 0}, {0, 0}},

    pictures = {
      picture = util.empty_sprite(),
      window_background = util.empty_sprite(),
      fluid_background = util.empty_sprite(),
      flow_sprite = util.empty_sprite(),
      gas_flow = util.empty_sprite(),
    },

    flow_length_in_ticks = 1,

    selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {},

    icons = {
      {
        icon = prototype.icon, icon_size = prototype.icon_size, icon_mipmaps = prototype.icon_mipmaps, tint = {1, 0.5, 0.5},
      },
    },

    flags = {
      'placeable-player',
      'placeable-off-grid',
      'not-on-map',
      -- 'hide-alt-info',
      -- 'not-selectable-in-game',
    },

    selection_priority = (prototype.selection_priority or 50) + 1,
  }

  data:extend{tank}

  local sprite = {
    type = 'sprite',
    name = prototype.name .. '-flushable',
    filename = "__base__/graphics/entity/fluid-wagon/hr-fluid-wagon-1.png",
    -- slice_x = 4,
    -- slice_y = 8,
    width = 416,
    height = 419,
    scale = 0.3,
    flags = {'no-crop'}
  }

  data:extend{sprite}
end
