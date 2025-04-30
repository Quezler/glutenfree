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

    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -0.4}, {0.4, 0.4}},

    minable = {mining_time = 0.2, result = "wood"},
    placeable_by = {item = "wood", count = 1},

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
