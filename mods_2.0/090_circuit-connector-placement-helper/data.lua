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

    flags = {"placeable-player", "placeable-off-grid", "not-on-map"},

    energy_usage = "1kW",
    energy_source = {type = "void"},
    crafting_speed = 1,
    crafting_categories = {mod_name},

    source_inventory_size = 0,
    result_inventory_size = 0,

    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.3, -0.3}, {0.3, 0.3}},

    circuit_connector = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
        { variation = i, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(0, 0), show_shadow = true },
      }
    )
  }}
end
