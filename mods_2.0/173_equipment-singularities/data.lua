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
