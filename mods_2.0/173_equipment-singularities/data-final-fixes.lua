local shared = require("shared")

---@type EquipmentSingularitiesModData
local mod_data = data.raw["mod-data"][mod_name].data

local item_prototypes = shared.get_item_prototypes()

local function for_item(item_name)
  local item_prototype = item_prototypes[item_name]
  if not item_prototype then return end

  local icons = {
    {icon = item_prototype.icon, scale = 0.50},
    {icon = item_prototype.icon, scale = 0.45},
    {icon = item_prototype.icon, scale = 0.40},
    {icon = item_prototype.icon, scale = 0.35},
  }

  local sprite = {
    layers = {
      {filename = item_prototype.icon, scale = 0.50, width = 64, height = 64},
      {filename = item_prototype.icon, scale = 0.45, width = 64, height = 64},
      {filename = item_prototype.icon, scale = 0.40, width = 64, height = 64},
      {filename = item_prototype.icon, scale = 0.35, width = 64, height = 64},
    }
  }

  local localised_name = {"equipment-singularities.singularity", item_prototype.localised_name or {"entity-name." .. item_name}}

  local item = {
    type = "item",
    name = mod_prefix .. item_name,
    localised_name = localised_name,
    icons = icons,
    order = item_prototype.order,
    subgroup = mod_name,

    stack_size = 1,
    flags = {"not-stackable"},
    weight = 1000 * kg,
    place_as_equipment_result = mod_prefix .. item_name,

  }

  local equipment = {
    type = "inventory-bonus-equipment",
    name = mod_prefix .. item_name,
    localised_name = localised_name,
    sprite = sprite,
    inventory_size_bonus = 1,
    shape = {
      type = "full",
      width = 1,
      height = 1,
    },
    take_result = mod_prefix .. item_name,
    categories = {"armor"},
  }

  -- local recipe = {
  --   type = "recipe",
  --   name = mod_prefix .. item_name,

  --   ingredients = {
  --     {type = "item", name = item_name, amount = 100000}
  --   },
  --   energy_required = 10,
  -- }

  data:extend{item, equipment}
end

for item_name, _ in pairs(mod_data["items"]) do
  for_item(item_name)
end
