require("shared")

local recipe_category = {
  type = "recipe-category",
  name = mod_prefix .. "pumping-speed",
}

local furnace = {
  type = "furnace",
  name = mod_prefix .. "pumping-speed",
  icon = mod_directory .. "/graphics/icons/washbox.png",

  -- selection_priority = 51,
  selection_priority = 49,
  selectable_in_game = false,
  selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
  collision_mask = {layers = {}},

  crafting_speed = data.raw["pump"]["pump"].pumping_speed * 60,
  crafting_categories = {recipe_category.name},

  source_inventory_size = 1,
  result_inventory_size = 1,

  energy_usage = "1kW",
  energy_source = {type = "void"},

  icon_draw_specification = {scale = 0},

  fluid_boxes =
  {
    {
      production_type = "input",
      volume = 100,
      pipe_connections = {
        -- {flow_direction = "input", direction = defines.direction.south, position = {0, 0.0}},
        {flow_direction = "input", connection_type = "linked", linked_connection_id = 1},
      },
    },
    {
      production_type = "output",
      volume = 100,
      pipe_connections = {
        -- {flow_direction = "output", direction = defines.direction.north, position = {0, 0.0}},
        {flow_direction = "output", connection_type = "linked", linked_connection_id = 0},
      },
    },
  },

  circuit_wire_max_distance = 9,
  default_recipe_finished_signal = {type = "virtual", name = "signal-S"}, -- 960 / 60 = 16

  flags = {"not-on-map", "placeable-off-grid", "no-automated-item-insertion", "no-automated-item-removal"},
  hidden = true,
}

data:extend{recipe_category, furnace}

for _, fluid in pairs(data.raw["fluid"]) do
  data:extend{{
    type = "recipe",
    name = mod_prefix .. "pumping-speed--" .. fluid.name,
    icon = "__core__/graphics/empty.png",
    icon_size = 1,

    enabled = true,
    energy_required = 1 / 60,
    category = recipe_category.name,

    ingredients = {{type = "fluid", name = fluid.name, amount = 1}},
    results = {{type = "fluid", name = fluid.name, amount = 1}},

    show_recipe_icon_on_map = false,
    hide_from_stats = true,
    hidden = true,
  }}
end
