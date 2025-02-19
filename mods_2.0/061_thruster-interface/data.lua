require("shared")

local entity = table.deepcopy(data.raw["thruster"]["thruster"])
entity.name = mod_name

entity.icons =
{{
  icon = entity.icon,
  tint = {0.5, 0.5, 1}
}}
entity.icon = nil

entity.min_performance = {fluid_volume =  0, fluid_usage =  0, effectivity =  1}
entity.max_performance = {fluid_volume = 10, fluid_usage = 10, effectivity = 10}

local item = table.deepcopy(data.raw["item"]["thruster"])
item.name = mod_name

item.icons = entity.icons
item.icon = nil

item.place_result = entity.name
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = mod_name,
  enabled = true,
  ingredients =
  {
    {type = "item", name = "thruster", amount = 1},
    {type = "item", name = "infinity-pipe", amount = 1},
  },
  energy_required = 1,
  results = {{type="item", name = item.name, amount=1}}
}

-- table.insert(thruster.fuel_fluid_box.pipe_connections, {
--   flow_direction = "input", connection_type = "linked", linked_connection_id = 1, position = {-1.5,  0},
-- })

-- table.insert(thruster.oxidizer_fluid_box.pipe_connections, {
--   flow_direction = "input", connection_type = "linked", linked_connection_id = 2, position = { 1.5,  0},
-- })

-- local pipe = table.deepcopy(data.raw["infinity-pipe"]["infinity-pipe"])
-- pipe.name = mod_prefix .. pipe.name
-- pipe.selection_priority = 51
-- pipe.minable = nil

-- pipe.icons =
-- {{
--   icon = thruster.icons[1].icon,
--   tint = {0.5, 0.5, 1}
-- }, pipe.icons[1]}

-- pipe.fluid_box.pipe_connections = {
--   {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 1},
-- }

data:extend{entity, item, recipe}
