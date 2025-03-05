require("shared")

local factories = {
  {
    i = 1,
    order = "a",
    selection_box = {{-4.0, -4.0}, {4.0, 4.0}},
    collision_box = {{-3.8, -3.8}, {3.8, 3.8}},
    max_health = 2000,
    container_size = 30,
    picture_properties = {
      width = 416 * 2,
      height = 320 * 2,
      scale = 0.5,
      shift = {1.5, 0},
    },
  },
  {
    i = 2,
    order = "b",
    selection_box = {{-6.0, -6.0}, {6.0, 6.0}},
    collision_box = {{-5.8, -5.8}, {5.8, 5.8}},
    max_health = 3500,
    container_size = 60,
    picture_properties = {
      width = 544 * 2,
      height = 448 * 2,
      scale = 0.5,
      shift = {1.5, 0},
    },
  },
  {
    i = 3,
    order = "c",
    selection_box = {{-8.0, -8.0}, {8.0, 8.0}},
    collision_box = {{-7.8, -7.8}, {7.8, 7.8}},
    max_health = 5000,
    container_size = 120,
    picture_properties = {
      width = 704 * 2,
      height = 608 * 2,
      scale = 0.5,
      shift = {2, -0.09375},
    },
  },
}

local alt_graphics = "-alt"
if mods["factorissimo-2-notnotmelon"] and settings.startup["Factorissimo2-alt-graphics"].value then
  alt_graphics = ""
end

for _, factory in ipairs(factories) do
  local container = {
    type = "container",
    name = mod_prefix .. "container-" .. factory.i,
    localised_name = {"entity-name.magic-huts--container-i", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),
    order = factory.order,

    selection_box = factory.selection_box,
    collision_box = factory.collision_box,
    max_health = factory.max_health,

    inventory_size = factory.container_size,
    inventory_type = "normal",

    flags = {"player-creation", "placeable-player"},

    -- the factory does not benefit from any quality bonuses
    quality_affects_inventory_size = false,
    quality_indicator_scale = 0,

    picture = {
      layers = {
        {
          filename = string.format(mod_directory .. "/graphics/factory/factory-%d-shadow.png", factory.i),
          draw_as_shadow = true
        },
        {
          filename = string.format(mod_directory .. "/graphics/factory/factory-%d" .. alt_graphics .. ".png", factory.i),
        }
      },
    },

    circuit_wire_max_distance = default_circuit_wire_max_distance,
  }

  for key, value in pairs(factory.picture_properties) do
    container.picture.layers[1][key] = value
    container.picture.layers[2][key] = value
  end

  data:extend{container}
end
