require("shared")

data:extend{{
  type = "recipe-category",
  name = mod_name,
}}

for i = 0, 39 do
  local two_character_number = string.format("%02d", i)

  data:extend{{
    type = "furnace",
    name = mod_prefix .. "furnace-" .. two_character_number,
    icon = mod_directory .. "/graphics/icons/variation-" .. two_character_number .. ".png",
    localised_name = {"entity-name.circuit-connector-placement-helper--furnace-xx", two_character_number},

    flags = {"placeable-player", "player-creation", "placeable-off-grid", "not-on-map"},

    energy_usage = "1kW",
    energy_source = {type = "void"},
    crafting_speed = 1,
    crafting_categories = {mod_name},

    source_inventory_size = 0,
    result_inventory_size = 0,

    collision_mask = {layers = {}},
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_priority = 255,

    minable = {mining_time = 0.2},
    placeable_by = {item = "red-wire", count = 1},

    graphics_set = {
      circuit_connector_layer = "higher-object-under",
    },

    circuit_wire_max_distance = default_circuit_wire_max_distance,
    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
      }
    ),

    -- makes it rotatable
    fluid_boxes = {{
      volume = 1,
      pipe_connections = {},
      production_type = "output",
    }},

    hidden = true,
  }}
end

data:extend{
  {
    type = "custom-input",
    key_sequence = "RIGHT",
    name = mod_prefix .. "right",
  },
  {
    type = "custom-input",
    key_sequence = "LEFT",
    name = mod_prefix .. "left",
  },
  {
    type = "custom-input",
    key_sequence = "DOWN",
    name = mod_prefix .. "down",
  },
  {
    type = "custom-input",
    key_sequence = "UP",
    name = mod_prefix .. "up",
  },
  {
    type = "custom-input",
    key_sequence = "SHIFT + RIGHT",
    name = mod_prefix .. "shift-right",
  },
  {
    type = "custom-input",
    key_sequence = "SHIFT + LEFT",
    name = mod_prefix .. "shift-left",
  },
  {
    type = "custom-input",
    key_sequence = "SHIFT + DOWN",
    name = mod_prefix .. "shift-down",
  },
  {
    type = "custom-input",
    key_sequence = "SHIFT + UP",
    name = mod_prefix .. "shift-up",
  },
}

local connector_book = table.deepcopy(data.raw["blueprint-book"]["blueprint-book"])
connector_book.name = mod_prefix .. "connector-book"
connector_book.icon = mod_directory .. "/graphics/icons/connector-book.png"
connector_book.hidden = true
-- table.insert(connector_book.flags, "only-in-cursor")
data:extend{connector_book}

data:extend{{
  type = "container",
  name = mod_prefix .. "container",
  icon = mod_directory .. "/graphics/icons/connector-book.png",

  collision_mask = {layers = {}},
  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
  selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_priority = 0,

  inventory_size = 0,
  flags = {"player-creation", "no-automated-item-insertion", "no-automated-item-removal", "not-selectable-in-game", "placeable-off-grid", "not-on-map"},

  circuit_wire_max_distance = default_circuit_wire_max_distance,
  draw_circuit_wires = false,

  minable = {mining_time = 0.2},
  placeable_by = {item = "green-wire", count = 1},

  hidden = true,
}}
