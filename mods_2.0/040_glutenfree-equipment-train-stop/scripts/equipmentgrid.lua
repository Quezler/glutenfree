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

local function get_nearby_container_inventories(entry)
  local inventories = {}

  local containers = entry.train_stop.surface.find_entities_filtered({
    type = {"container", "logistic-container"},
    position = entry.train_stop.position,
    radius = 2
  })

  for _, container in ipairs(containers) do
    if container ~= entry.template_container then
      inventories[container.unit_number] = container.get_inventory(defines.inventory.chest)
    end
  end

  return inventories
end

local function try_with_inventories(inventories, operation, equipment)
  local item = {name = equipment.name, quality = equipment.quality, count = 1}
  for _, inventory in pairs(inventories) do
      if inventory[operation](item) == 1 then
        return inventory
      end
  end
  return nil
end

local function is_ghost(equipment)
  return equipment.name == "equipment-ghost"
end

function EquipmentGrid.tick_rolling_stock(entry, entity)

  local grid = entity.grid
  if not grid then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "no-equipment-grid-found"}) end

  local template_inventory = entry.template_container.get_inventory(defines.inventory.chest)
  if template_inventory.is_empty() then return EquipmentGrid.flying_text(entry.train_stop, {locale_prefix .. "template-chest-is-empty"}) end

  local template = template_inventory.find_item_stack({name = prototypes.entity[entity.name].items_to_place_this[1].name, quality = entity.quality})
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

  local removal_requests = {}
  local add_requests = {}

  -- Track existing equipment
  for _, equipment in ipairs(grid.equipment) do
    removal_requests[util.positiontostr(equipment.position)] = equipment
  end

  -- Compare with expected equipment
  for _, expected in ipairs(template.grid.equipment) do
    local position_str = util.positiontostr(expected.position)
    local actual = removal_requests[position_str]
    if actual then
      if actual.name == expected.name and actual.quality == expected.quality then
        -- Equipment matches, so keep it
        removal_requests[position_str] = nil
        grid.cancel_removal(actual)
      else
        -- Equipment does not match or ghost, so prepare to add the expected one
        add_requests[position_str] = expected
        if is_ghost(actual) and actual.ghost_name == expected.name and actual.quality == expected.quality then
          -- keep the ghost to prevent restarting the logistic request
          removal_requests[position_str] = nil 
        end
      end
    else
      -- no equipment present, so prepare to add the expected one
      add_requests[position_str] = expected
    end
  end
  
  local nearby_inventories = get_nearby_container_inventories(entry)

  -- first remove all bad equipment from the grid, to avoid issues with overlapping elements
  for _, equipment in pairs(removal_requests) do
    if not is_ghost(equipment) and try_with_inventories(nearby_inventories, "insert", equipment) then
        grid.take({ equipment = equipment })
    else
      grid.order_removal(equipment)
    end
  end

  -- then add the new equipment
  for _, equipment in pairs(add_requests) do
    local source_inventory = try_with_inventories(nearby_inventories, "remove", equipment)
    if source_inventory then
      if not grid.put({
        name = equipment.name,
        quality = equipment.quality,
        position = equipment.position,
      }) then
        -- the space is still occupied (with an equipment marked for removal), put item back
        source_inventory.insert({ 
          name = equipment.name, 
          quality = equipment.quality, 
          count = 1 
        })
        grid.put({
          name = equipment.name,
          quality = equipment.quality,
          position = equipment.position,
          ghost = true,
        })
      end
    else
      grid.put({
        name = equipment.name,
        quality = equipment.quality,
        position = equipment.position,
        ghost = true,
      })
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
