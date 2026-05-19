local shared = require("shared")

---@class EquipmentSingularitiesModData
---@field items table<string, true>

---@type EquipmentSingularitiesModData
local mod_data = {
  items = util.list_to_map({
    "rail",
  })
}

data:extend{
  {
    type = "mod-data",
    name = mod_name,
    data = mod_data,
  },
  {
    type = "item-subgroup",
    name = mod_name,
    group = "logistics",
    order = "j",
  }
}

local item_prototypes = shared.get_item_prototypes()
local entity_prototypes = shared.get_entity_prototypes()

local simple_entity_types = util.list_to_map({
  "transport-belt",
  "electric-pole",
  "inserter",
})

---@param item data.ItemPrototype
local function places_simple_building(item)
  if not item.place_result then return end

  local entity = entity_prototypes[item.place_result]
  if not entity then return end

  if simple_entity_types[entity.type] then
    return true
  end
end

for _, item in pairs(item_prototypes) do
  if places_simple_building(item) then
    mod_data.items[item.name] = true
  end
end

local chest_entity = table.deepcopy(data.raw["container"]["bottomless-chest"])
chest_entity.name = mod_prefix .. "chest"
chest_entity.hidden = false
chest_entity.inventory_properties = {
  stack_size_multiplier = 0,
  stack_size_override = {}
}
table.insert(chest_entity.flags, "no-automated-item-removal")

local chest_item = table.deepcopy(data.raw["item"]["bottomless-chest"])
chest_item.name = mod_prefix .. "chest"
chest_item.hidden = false
chest_item.subgroup = "storage"
chest_item.stack_size = 1
chest_item.order = "a[items]-d[steel-chest]"
chest_item.place_result = chest_entity.name
chest_entity.minable.result = chest_item.name

local chest_recipe = {
  type = "recipe",
  name = mod_prefix .. "chest",
  ingredients = {
    {type = "item", name = "steel-chest", amount = 1},
    {type = "item", name = "coal", amount = 50},
  },
  results = {{type="item", name=mod_prefix .. "chest", amount=1}},
  enabled = false
}

table.insert(data.raw["technology"]["steel-processing"].effects, {type = "unlock-recipe", recipe = chest_recipe.name})

data:extend{chest_entity, chest_item, chest_recipe}
