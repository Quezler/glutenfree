require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local function shift_bounding_box_up_by_one(bounding_box)
  return {{bounding_box[1][1], bounding_box[1][2] - 1}, {bounding_box[2][1], bounding_box[2][2] - 1}}
end

local selection_boxes = {
  lab    = {{-0.5, -0.5}, {0.5, 0.5}},
  biolab = {{ 0.3,  0.5}, {1.3, 1.5}},
}

circuit_connector_definitions["lab-control-behavior"] = circuit_connector_definitions.create_single
(
  universal_connector_template,
  { variation = 0, main_offset = util.by_pixel(4.5, 2), shadow_offset = util.by_pixel(4.5, 7.5)}
)
-- circuit_connector_definitions["lab-control-behavior"].sprites = {
--   wire_pins = circuit_connector_definitions["lab-control-behavior"].sprites.wire_pins,
--   wire_pins_shadow = circuit_connector_definitions["lab-control-behavior"].sprites.wire_pins_shadow,
-- }
circuit_connector_definitions["lab-control-behavior"].sprites.connector_main = nil
circuit_connector_definitions["lab-control-behavior"].sprites.connector_shadow = nil
circuit_connector_definitions["lab-control-behavior"].sprites.led_red = util.empty_sprite()
circuit_connector_definitions["lab-control-behavior"].sprites.led_green = util.empty_sprite()
circuit_connector_definitions["lab-control-behavior"].sprites.led_blue = util.empty_sprite()

for _, lab in pairs(data.raw["lab"]) do
  local lab_control_behavior = {
    type = "proxy-container",
    name = mod_prefix .. lab.name .. "-control-behavior",
    localised_name = {"entity-name.lab-control-behavior--x-control-behavior", {"entity-name." .. lab.name}},

    icons = {
      {icon = lab.icon, tint = proxy_tint},
    },

    collision_box = shift_bounding_box_up_by_one(lab.collision_box),
    selection_box = selection_boxes[lab.name] or selection_boxes.lab,
    collision_mask = {layers = {}},

    flags = {"not-on-map", "player-creation", "no-automated-item-insertion", "no-automated-item-removal"},
    draw_inventory_content = false,
    selection_priority = 51,
    hidden = true,

    circuit_wire_max_distance = 9,
    circuit_connector = circuit_connector_definitions["lab-control-behavior"],
  }

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
  draw_inventory_content = false,
  selection_priority = 49,
  hidden = true,
}

data:extend{proxy_container}
