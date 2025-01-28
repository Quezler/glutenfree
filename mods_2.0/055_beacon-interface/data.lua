local mod_prefix = "beacon-interface--"
local debug_mode = true

local icons = {
  {icon = "__beacon-interface__/graphics/icons/beacon.png"},
  {icon = "__beacon-interface__/graphics/icons/compilatron.png", scale = 0.375, shift = {-8, 8}},
}

local entity = table.deepcopy(data.raw["beacon"]["beacon"])
entity.name = mod_prefix .. "beacon"
entity.icon = nil
entity.icons = icons
entity.module_slots = 16 * 5
entity.graphics_set.module_visualisations = nil

table.insert(entity.graphics_set.animation_list, {
  render_layer = "cargo-hatch",
  animation = {
    filename = "__beacon-interface__/graphics/entity/beacon-interface/drone_walk_frame_14.png",
    width = 79,
    height = 104,
    scale = 0.375,
    shift = util.by_pixel(-15, 10)
  }
})

local item = table.deepcopy(data.raw["item"]["beacon"])
item.name = mod_prefix .. "beacon"
item.icon = nil
item.icons = icons

entity.minable.result = item.name
item.place_result = entity.name

if debug_mode then
  local recipe = {
    type = "recipe",
    name = mod_prefix .. "beacon",
    enabled = false,
    energy_required = 5,
    ingredients = {},
    results = {{type="item", name = item.name, amount=1}}
  }
  data:extend{recipe}
  table.insert(data.raw["technology"]["effect-transmission"].effects, {type = "unlock-recipe", recipe = recipe.name})
end

data:extend{entity, item}
