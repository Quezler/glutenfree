require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local function shift_bounding_box_up_by_one(bounding_box)
  return {{bounding_box[1][1], bounding_box[1][2] - 1}, {bounding_box[2][1], bounding_box[2][2] - 1}}
end

local configs = {
  lab = {
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    circuit_definition = {variation = 0, main_offset = util.by_pixel(4.5, 2.0), shadow_offset = util.by_pixel(4.5, 2.0 + 2)},
  },
  biolab = {
    selection_box = {{ 0.5,  0.5}, {1.5, 1.5}},
    circuit_definition = {variation = 0, main_offset = util.by_pixel(32.5, 32.5), shadow_offset = util.by_pixel(32.5, 32.5 + 2)},
  },
}

for _, lab in pairs(data.raw["lab"]) do
  local config = table.deepcopy(configs[lab.name] or configs["lab"])
  local lab_control_behavior = {
    type = "proxy-container",
    name = mod_prefix .. lab.name .. "-control-behavior",
    localised_name = {"entity-name.lab-control-behavior--x-control-behavior", {"entity-name." .. lab.name}},

    icons = {
      {icon = lab.icon},
      {icon = mod_directory .. "/graphics/icons/lab-control-behavior-overlay.png", icon_size = 23, scale = 1, shift = {0, 8}, draw_background = true, floating = true},
    },

    collision_box = shift_bounding_box_up_by_one(lab.collision_box),
    selection_box = config.selection_box,
    collision_mask = {layers = {}},

    flags = {"not-on-map", "player-creation", "no-automated-item-insertion", "no-automated-item-removal"},
    draw_inventory_content = false,
    selection_priority = 51,
    hidden = true,

    circuit_wire_max_distance = 9,
  }

  lab_control_behavior.circuit_connector = circuit_connector_definitions.create_single
  (
    universal_connector_template,
    config.circuit_definition
  )

  lab_control_behavior.circuit_connector.sprites.connector_main = nil
  lab_control_behavior.circuit_connector.sprites.connector_shadow = nil
  lab_control_behavior.circuit_connector.sprites.led_red = util.empty_sprite()
  lab_control_behavior.circuit_connector.sprites.led_green = util.empty_sprite()
  lab_control_behavior.circuit_connector.sprites.led_blue = util.empty_sprite()
  lab_control_behavior.circuit_connector.sprites.led_blue_off = nil

  data:extend{lab_control_behavior}
end

local base_lab = data.raw["lab"]["lab"]

local proxy_container = {
  type = "proxy-container",
  name = mod_prefix .. "proxy-container",

  icons = {
    {icon = base_lab.icon, tint = proxy_tint},
  },

  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  collision_mask = {layers = {}},

  flags = {"not-on-map", "no-automated-item-insertion", "no-automated-item-removal"},
  draw_circuit_wires = false,
  draw_inventory_content = false,
  selection_priority = 49,
  hidden = true,
}

data:extend{proxy_container}
