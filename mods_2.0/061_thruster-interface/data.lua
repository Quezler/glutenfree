require("util")
require("shared")

local space_age_thruster = data.raw["thruster"]["thruster"]

local entity = table.deepcopy(space_age_thruster)
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

entity.min_performance = {fluid_volume = 1, fluid_usage = 2, effectivity = 0}
entity.max_performance = {fluid_volume = 1, fluid_usage = 2, effectivity = 0}

entity.fuel_fluid_box.hide_connection_info = true
entity.fuel_fluid_box.pipe_connections = {
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 1},
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 2},
}
entity.oxidizer_fluid_box.hide_connection_info = true
entity.oxidizer_fluid_box.pipe_connections = {
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 3},
  {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 4},
}

-- table.insert(entity.flags, "get-by-unit-number")
entity.plumes = nil

local item = table.deepcopy(data.raw["item"]["thruster"])
item.name = mod_name

item.icons = entity.icons
item.icon = nil

item.place_result = entity.name
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = mod_name,
  enabled = false,
  ingredients = {},
  energy_required = 1,
  results = {{type="item", name = item.name, amount=1}},
  auto_recycle = false,
}

local pipe = table.deepcopy(data.raw["infinity-pipe"]["infinity-pipe"])
pipe.name = mod_prefix .. pipe.name
pipe.selection_priority = 49
pipe.selectable_in_game = false
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
pipe.flags = {"not-on-map", "hide-alt-info"}
pipe.pictures = nil
pipe.collision_mask = {layers = {}}

data:extend{entity, item, recipe, pipe}

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "open-gui",
    linked_game_control = "open-gui",
    -- include_selected_prototype = true,
  }
})

local thruster = table.deepcopy(entity)
thruster.name = mod_prefix .. "thruster"
thruster.graphics_set = nil
thruster.minable = nil
thruster.selection_priority = 48
thruster.selectable_in_game = false
thruster.quality_indicator_scale = 0
thruster.min_performance = table.deepcopy(space_age_thruster.min_performance)
thruster.max_performance = table.deepcopy(space_age_thruster.max_performance)
thruster.collision_mask = {layers = {}}
thruster.fast_replaceable_group = nil
data:extend{thruster}

if mods["EditorExtensions"] then
  recipe.category = "ee-testing-tool"

  data:extend({
    {
      type = "item-subgroup",
      name = "ee-quezler",
      group = "ee-tools",
      order = "q",
    },
  })

  item.subgroup = "ee-quezler"
end
