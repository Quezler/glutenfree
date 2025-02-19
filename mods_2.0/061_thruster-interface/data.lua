require("util")
require("shared")

local entity = table.deepcopy(data.raw["thruster"]["thruster"])
entity.name = mod_name

entity.icons =
{{
  icon = entity.icon,
  tint = {0.5, 0.5, 1}
}}
entity.icon = nil

entity.graphics_set.animation = util.sprite_load("__space-age__/graphics/entity/thruster/thruster",
{
  animation_speed = 0.5,
  frame_count = 64,
  scale = 0.5,
  shift = {0, 3},
  tint = {0.5, 0.5, 1},
})
entity.graphics_set.integration_patch = util.sprite_load("__space-age__/graphics/entity/thruster/thruster-bckg",
{
  scale = 0.5,
  shift = {0, 3},
  tint = {0.5, 0.5, 1},
})

entity.min_performance = {fluid_volume = 0, fluid_usage = 0.0, effectivity = 0}
entity.max_performance = {fluid_volume = 1, fluid_usage = 0.1, effectivity = 0}

entity.fuel_fluid_box.pipe_connections = {
  {flow_direction = "input", connection_type = "linked", linked_connection_id = 1},
  {flow_direction = "output", connection_type = "linked", linked_connection_id = 2},
}
entity.oxidizer_fluid_box.pipe_connections = {
  {flow_direction = "input", connection_type = "linked", linked_connection_id = 3},
  {flow_direction = "output", connection_type = "linked", linked_connection_id = 4},
}

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

local pipe = table.deepcopy(data.raw["infinity-pipe"]["infinity-pipe"])
pipe.name = mod_prefix .. pipe.name
pipe.selection_priority = 51
pipe.minable = nil

pipe.icons =
{{
  icon = entity.icons[1].icon,
  tint = {0.5, 0.5, 1}
}, pipe.icons[1]}

pipe.fluid_box.pipe_connections = {
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 0},
}

pipe.gui_mode = "none"

data:extend{entity, item, recipe, pipe}
