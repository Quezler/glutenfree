local shared = require("shared")
local debug_mode = false

local icons = {
  {icon = "__base__/graphics/icons/beacon.png"},
  {icon = "__beacon-interface__/graphics/icons/compilatron.png", scale = 0.375, shift = {-4, 4}},
}

local entity = table.deepcopy(data.raw["beacon"]["beacon"])
entity.name = mod_prefix .. "beacon"
entity.icon = nil
entity.icons = icons
entity.module_slots = 16 * 5 -- there will be 16 "bits" at most per effect, and there are 5 effects
entity.graphics_set = require("__base__.prototypes.entity.beacon-animations")
entity.graphics_set.module_visualisations = nil
entity.graphics_set.animation_list[1].animation.layers[1].filename = "__beacon-interface__/graphics/entity/beacon-interface/beacon-interface-bottom.png"
entity.allowed_effects = shared.effects
entity.allowed_module_categories = {mod_prefix .. "module-category"}
entity.distribution_effectivity = 1
entity.distribution_effectivity_bonus_per_quality_level = 0
entity.icons_positioning = {
  {inventory_index = defines.inventory.beacon_modules, scale = 0},
}
entity.next_upgrade = nil
table.insert(entity.flags, "no-automated-item-removal")
table.insert(entity.flags, "no-automated-item-insertion")
entity.hidden = true

if mods["space-exploration"] then
  entity.se_allow_in_space = true
  entity.se_allow_productivity_in_space = true
end

if mods["Voidcraft"] then
  entity.vc_ignore = true
end

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

data:extend({
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "open-gui",
    linked_game_control = "open-gui",
    include_selected_prototype = true,
  }
})

local tile_beacon = table.deepcopy(entity)
tile_beacon.name = mod_prefix .. "beacon-tile"
tile_beacon.icons[1].icon = "__base__/graphics/icons/hazard-concrete.png"

tile_beacon.max_health = 1
tile_beacon.minable = nil
tile_beacon.profile = {1}
tile_beacon.beacon_counter = "same_type" -- does this do anything if the profile is {1}?
tile_beacon.graphics_set = nil
tile_beacon.supply_area_distance = 0
tile_beacon.selection_box = {{-0.35, -0.35}, {0.35, 0.35}}
tile_beacon.collision_box = {{-0.45, -0.45}, {0.45, 0.45}}
tile_beacon.collision_mask = {layers = {}}
tile_beacon.selection_priority = 51
tile_beacon.selectable_in_game = debug_mode
table.insert(entity.flags, "not-on-map")
tile_beacon.energy_source = {type = "void"}
tile_beacon.heating_energy = nil

data:extend{tile_beacon}
