local mod_prefix = "beacon-interface--"
local shared = require("shared")
local debug_mode = true

local icons = {
  {icon = "__beacon-interface__/graphics/icons/beacon.png"},
  {icon = "__beacon-interface__/graphics/icons/compilatron.png", scale = 0.375, shift = {-4, 4}},
}

local entity = table.deepcopy(data.raw["beacon"]["beacon"])
entity.name = mod_prefix .. "beacon"
entity.icon = nil
entity.icons = icons
entity.module_slots = 16 * 5
entity.graphics_set.module_visualisations = nil
entity.graphics_set.animation_list[1].animation.layers[1].filename = "__beacon-interface__/graphics/entity/beacon-interface/beacon-interface-bottom.png"
table.insert(entity.flags, "hide-alt-info")
entity.allowed_effects = shared.effects
entity.allowed_module_categories = {mod_prefix .. "module-category"}
entity.distribution_effectivity = 1
entity.distribution_effectivity_bonus_per_quality_level = 0

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
