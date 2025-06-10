local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local sounds = require("__base__.prototypes.entity.sounds")

require("shared")
require("prototypes.planet")

local factories = {
  {
    i = 1,
    order = "c-a",
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
    ingredients = {
      {type = "item", name = "wooden-chest", amount = 1},
    },
    per_rocket = 4,
  },
  {
    i = 2,
    order = "c-b",
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
    ingredients = {
      {type = "item", name = "iron-chest", amount = 1},
    },
    per_rocket = 2,
  },
  {
    i = 3,
    order = "c-c",
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
    ingredients = {
      {type = "item", name = "steel-chest", amount = 1},
    },
    per_rocket = 1,
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
    inventory_type = "with_filters_and_bar",

    flags = {"player-creation", "placeable-player"},

    -- the factory does not benefit from any quality bonuses
    quality_affects_inventory_size = false,

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
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,
    impact_category = "metal",
  }

  for key, value in pairs(factory.picture_properties) do
    container.picture.layers[1][key] = value
    container.picture.layers[2][key] = value
  end

  local item = {
    type = "item",
    name = container.name,
    icon = container.icon,
    subgroup = "tool",
    order = factory.order,
    inventory_move_sound = item_sounds.metal_chest_inventory_move,
    pick_sound = item_sounds.metal_chest_inventory_pickup,
    drop_sound = item_sounds.metal_chest_inventory_move,
    place_result = container.name,
    stack_size = 1,
    flags = {"not-stackable"},
    random_tint_color = item_tints.iron_rust,
    weight = 1000*kg / factory.per_rocket,
  }

  container.minable = {mining_time = 0.5, result = item.name}

  local recipe = {
    type = "recipe",
    name = item.name,
    enabled = true,
    ingredients = factory.ingredients,
    results = {{type="item", name=item.name, amount=1}}
  }

  local crafter = {
    type = "assembling-machine",
    name = mod_prefix .. "crafter-" .. factory.i,
    localised_name = {"entity-name.magic-huts--crafter-i", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),
    order = factory.order,

    selection_priority = 51,
    selection_box = factory.selection_box,
    collision_box = factory.collision_box,
    collision_mask = {layers = {}},

    crafting_speed = 1,
    crafting_categories = {"crafting"},

    energy_usage = "1kW",
    energy_source = {type = "electric", usage_priority = "secondary-input"},
  }

  data:extend{container, item, recipe, crafter}
end
