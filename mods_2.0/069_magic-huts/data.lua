local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local sounds = require("__base__.prototypes.entity.sounds")

require("shared")
require("prototypes.planet")
require("prototypes.mod-data")

local function each_tile_edge_position(side_length, social_distancing)
  local positions = {}
  local half = side_length / 2

  for i = 1, side_length do
    local x = -half + 0.5 + (i - 1)
    local y = -half + 0.5
    table.insert(positions, {x = x, y = y + social_distancing, direction = defines.direction.north})
  end

  for i = 1, side_length do
    local x = -half + 0.5 + (i - 1)
    local y = half - 0.5
    table.insert(positions, {x = x, y = y - social_distancing, direction = defines.direction.south})
  end

  for i = 1, side_length do
    local y = -half + 0.5 + (i - 1)
    local x = half - 0.5
    table.insert(positions, {x = x - social_distancing, y = y, direction = defines.direction.east})
  end

  for i = 1, side_length do
    local y = -half + 0.5 + (i - 1)
    local x = -half + 0.5
    table.insert(positions, {x = x + social_distancing, y = y, direction = defines.direction.west})
  end

  return positions
end

local function get_fluidboxes(side_length)
  local fluidboxes = {}

  for _, position in ipairs(each_tile_edge_position(side_length, 0.001)) do
    table.insert(fluidboxes, {
      production_type = "input",
      volume = 1,
      hide_connection_info = true,
      pipe_connections = {
        {
          flow_direction = "input-output",
          position = position,
          direction = position.direction,
          connection_type = "underground",
          max_underground_distance = 1,
        },
      },
    })
  end

  return fluidboxes
end

local factories = {
  {
    i = 1,
    order = "c-a",
    selection_box = {{-4.0, -4.0}, {4.0, 4.0}},
    selection_box_door = {{-1.0, 2.1}, {1.0, 4.0}},
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
    eei_shift = {0, 2.1},
    side_length = 8,
  },
  {
    i = 2,
    order = "c-b",
    selection_box = {{-6.0, -6.0}, {6.0, 6.0}},
    selection_box_door = {{-1.5, 3.8}, {1.5, 6.0}},
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
    eei_shift = {0, 3.6},
    side_length = 12,
  },
  {
    i = 3,
    order = "c-c",
    selection_box = {{-8.0, -8.0}, {8.0, 8.0}},
    selection_box_door = {{-1.8, 5.5}, {1.8, 8.0}},
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
    eei_shift = {0, 5.5},
    side_length = 16,
  },
}

local alt_graphics = "-alt"
if mods["factorissimo-2-notnotmelon"] and settings.startup["Factorissimo2-alt-graphics"].value then
  alt_graphics = ""
end

local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "recipe-category",
}
data:extend{recipe_category}

for _, factory in ipairs(factories) do
  local container = {
    type = "container",
    name = mod_prefix .. "container-" .. factory.i,
    localised_name = {"entity-name.magic-hut", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),
    order = factory.order,

    selection_box = factory.selection_box,
    collision_box = factory.collision_box,
    max_health = factory.max_health,

    inventory_size = factory.container_size,
    inventory_type = "with_filters_and_bar",

    flags = {"player-creation", "placeable-player"},

    -- the factory does not benefit from any quality bonuses
    -- quality_affects_inventory_size = false,

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

    icon_draw_specification = {scale = 0, scale_for_many = 0},
    icons_positioning = {
      {inventory_index = defines.inventory.chest, shift = util.by_pixel(0, -70), max_icons_per_row = 1, max_icon_rows = 1, scale = 1, separation_multiplier = 0},
    }
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

  local crafter_recipe = {
    type = "recipe",
    name = mod_prefix .. "recipe-" .. factory.i,
    localised_name = {"entity-name.magic-hut", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),
    category = recipe_category.name,
    enabled = true,
    auto_recycle = false,
    energy_required = 60,
    ingredients = {},
    results = {},
    hide_from_player_crafting = true,
    hidden_in_factoriopedia = true,
  }

  local crafter_a = {
    type = "assembling-machine",
    name = mod_prefix .. "crafter-a-" .. factory.i,
    localised_name = {"entity-name.magic-hut", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),
    order = factory.order,

    selection_priority = 51,
    selection_box = factory.selection_box_door,
    collision_box = factory.collision_box,
    collision_mask = {layers = {}},

    crafting_speed = 1,
    crafting_categories = {recipe_category.name},

    energy_usage = "1kW",
    energy_source = {type = "electric", usage_priority = "secondary-input"},

    fixed_recipe = crafter_recipe.name,
    fixed_quality = "normal",

    icon_draw_specification = {scale = 0},
    hidden = true,

    flags = {"no-automated-item-insertion", "no-automated-item-removal"},
  }

  -- a crafter with a recipe set force-disables all unused fluidboxes
  local crafter_b = table.deepcopy(crafter_a)
  crafter_b.name = mod_prefix .. "crafter-b-" .. factory.i
  crafter_b.selection_box = factory.selection_box
  crafter_b.fixed_recipe = nil
  crafter_b.fixed_quality = nil
  crafter_b.fluid_boxes = get_fluidboxes(factory.side_length)
  crafter_b.selection_priority = 49
  crafter_b.energy_source = {type = "void"}

  local eei = {
    type = "electric-energy-interface",
    name = mod_prefix .. "eei-" .. factory.i,
    localised_name = {"entity-name.magic-hut", tostring(factory.i)},
    icon = string.format(mod_directory .. "/graphics/icons/factory-%d.png", factory.i),

    selection_priority = 52,
    selection_box = {{-0.4, -0.3 + factory.eei_shift[2]}, {0.4, 0.3 + factory.eei_shift[2]}},
    collision_box = factory.collision_box,
    collision_mask = {layers = {}},

    -- gui_mode = "all",
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      render_no_power_icon = false,
      render_no_network_icon = false,
    },

    render_layer = "cargo-hatch",
    picture = {
      filename = mod_directory .. '/graphics/entity/amongus-electric-energy-interface.png',
      width = 30,
      height = 20,
      scale = 0.5,
      shift = factory.eei_shift,
    },
    hidden = true,
  }

  data:extend{container, item, recipe, crafter_recipe, crafter_a, crafter_b, eei}
end

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "build",
    linked_game_control = "build",
    include_selected_prototype = true,
  }
})

data:extend{{
  type = "item",
  name = mod_prefix .. "empty-filter",
  icon = "__core__/graphics/empty.png",
  icon_size = 1,
  stack_size = 1,
  hidden = true,
}}

if mods["FilterHelper"] and data.raw["mod-data"]["fh_add_items_drop_target_entity"] and data.raw["mod-data"]["fh_add_items_pickup_target_entity"] then
  data.raw["mod-data"]["fh_add_items_drop_target_entity"].data[mod_prefix .. "container-" .. 1] = {"magic-huts", "fh_add_items_drop_target_entity"}
  data.raw["mod-data"]["fh_add_items_drop_target_entity"].data[mod_prefix .. "container-" .. 2] = {"magic-huts", "fh_add_items_drop_target_entity"}
  data.raw["mod-data"]["fh_add_items_drop_target_entity"].data[mod_prefix .. "container-" .. 3] = {"magic-huts", "fh_add_items_drop_target_entity"}

  data.raw["mod-data"]["fh_add_items_pickup_target_entity"].data[mod_prefix .. "container-" .. 1] = {"magic-huts", "fh_add_items_pickup_target_entity"}
  data.raw["mod-data"]["fh_add_items_pickup_target_entity"].data[mod_prefix .. "container-" .. 2] = {"magic-huts", "fh_add_items_pickup_target_entity"}
  data.raw["mod-data"]["fh_add_items_pickup_target_entity"].data[mod_prefix .. "container-" .. 3] = {"magic-huts", "fh_add_items_pickup_target_entity"}
end
