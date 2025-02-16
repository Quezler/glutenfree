require("shared")

local thruster = table.deepcopy(data.raw["thruster"]["thruster"])
thruster.name = mod_name
thruster.minable.result = nil

thruster.icons =
{{
  icon = thruster.icon,
  tint = {0.5, 0.5, 1}
}}
thruster.icon = nil

table.insert(thruster.fuel_fluid_box.pipe_connections, {
  flow_direction = "input", connection_type = "linked", linked_connection_id = 1, position = {-1.5,  0},
})

table.insert(thruster.oxidizer_fluid_box.pipe_connections, {
  flow_direction = "input", connection_type = "linked", linked_connection_id = 2, position = { 1.5,  0},
})

local pipe = table.deepcopy(data.raw["infinity-pipe"]["infinity-pipe"])
pipe.name = mod_prefix .. pipe.name
pipe.selection_priority = 51
pipe.minable = nil

pipe.icons =
{{
  icon = thruster.icons[1].icon,
  tint = {0.5, 0.5, 1}
}, pipe.icons[1]}

pipe.fluid_box.pipe_connections = {
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 1},
}

data:extend{thruster, pipe}
