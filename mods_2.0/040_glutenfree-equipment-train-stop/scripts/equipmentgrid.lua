require("util")

local locale_prefix = "glutenfree-equipment-train-stop."

local EquipmentGrid = {}

-- note: equipment_grid.equipment is based on *insertion* order, you cannot just compare the two and expect them to match!

-- the "map" part suggests to not 1-1 compare this based on key insertion order
local function get_contents_with_quality_map(equipment_grid)
  local map = {}

  for _, equipment in ipairs(equipment_grid.equipment) do
    local key = equipment.quality.name .. ' ' .. equipment.name
    map[key] = (map[key] or 0) + 1
  end

  return map
end

function EquipmentGrid.tick_rolling_stock(entry, entity)

  local grid = entity.grid
  if not grid then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "no-equipment-grid-found"}) end

  local template_inventory = entry.template_container.get_inventory(defines.inventory.chest)
  if template_inventory.is_empty() then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "template-chest-is-empty"}) end

  local placement_items = prototypes.entity[entity.name].items_to_place_this
  if not placement_items or #placement_items == 0 then
    return -- Nothing the player can do anything about -> silently ignore
  end
  local template = template_inventory.find_item_stack({name = placement_items[1].name, quality = entity.quality})
  if not template then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "missing-template-for", entity.localised_name, entity.quality.localised_name}) end
  if not template.grid then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "template-equipment-grid-empty"}) end

  local contents = get_contents_with_quality_map(grid)
  -- {
  --   ["normal imersite-solar-panel-equipment"] = 1
  -- }

  local template_contents = get_contents_with_quality_map(template.grid)
  -- {
  --   ["normal advanced-additional-engine"] = 6,
  --   ["normal big-battery-equipment"] = 5,
  --   ["normal big-imersite-solar-panel-equipment"] = 5,
  --   ["normal energy-shield-equipment"] = 1,
  --   ["normal personal-laser-defense-mk2-equipment"] = 1
  -- }

  -- check if the grid has the same amount of everything as the template, regardless of position. (cheap bail check)
  if EquipmentGrid.contents_are_equal(template_contents, contents) then return end

  local removal_request = {}
  for _, equipment in ipairs(grid.equipment) do
    removal_request[util.positiontostr(equipment.position)] = {
      name = equipment.name,
      quality = equipment.quality,
    }
    grid.order_removal(equipment)
  end

  for _, equipment in ipairs(template.grid.equipment) do
    local to_remove = removal_request[util.positiontostr(equipment.position)]
    if to_remove and to_remove.name == equipment.name and to_remove.quality == equipment.quality then
      grid.cancel_removal(grid.get(equipment.position))
    else
      -- the new ghost can collide with equipment removal requests, but sometimes it _does_ overlap, weird right?
      local success = grid.put{
        name = equipment.name,
        quality = equipment.quality,
        position = equipment.position,
        ghost = true,
      }
    end
  end

end

-- this does not care about the position inside
function EquipmentGrid.contents_are_equal(a, b)
  if table_size(a) ~= table_size(b) then return false end

  for item, count in pairs(a) do
    if b[item] == nil then return false end
    if b[item] ~= count then return false end
  end

  return true
end

function EquipmentGrid.flying_text(entity, text)
  rendering.draw_text{
    text = text,
    color = {1, 1, 1},
    target = entity.position,
    surface = entity.surface,
    time_to_live = 60,
    alignment = "center",
    scale = 0.75,
  }
end

return EquipmentGrid
