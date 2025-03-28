for _, prototype in pairs(data.raw["fluid-wagon"]) do

  local tank = {
    type = "storage-tank",
    name = prototype.name .. "-flushable",
    localised_name = {"entity-name." .. prototype.name},

    fluid_box = {
      pipe_connections = {},
      volume = prototype.capacity,
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
    collision_mask = {layers = {}},

    flags = {
      "placeable-player",
      "placeable-off-grid",
      "not-on-map",
      "hide-alt-info",
    },

    selection_priority = (prototype.selection_priority or 50) + 1,
    selectable_in_game = false,
    hidden = true,
  }

  tank.icons = prototype.icons or {
    {
      icon = prototype.icon, icon_size = prototype.icon_size, tint = {1, 0.5, 0.5},
    },
  }

  data:extend{tank}
end
