require("shared")

local proxy_tint = {0.8, 0.1, 0.3}

local function shift_bounding_box_up_by_one(bounding_box)
  return {{bounding_box[1][1], bounding_box[1][2] - 1}, {bounding_box[2][1], bounding_box[2][2] - 1}}
end

local selection_boxes = {
  lab    = {{-0.5, -0.5}, {0.5, 0.5}},
  biolab = {{ 0.3,  0.5}, {1.3, 1.5}},
}

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
  }

  data:extend{lab_control_behavior}
end
