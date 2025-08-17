require("util")

local locale_prefix = "glutenfree-equipment-train-stop."
local equipment_ghost = "equipment-ghost"

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

local function get_nearby_container(entry)
  local nearby_containers = entry.train_stop.surface.find_entities_filtered({
    type = {"container", "logistic-container"},
    position = entry.train_stop.position,
    radius = 2
  })

  for _, value in ipairs(nearby_containers) do
    if value ~= entry.template_container then
      return value
    end
  end
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

  local removal_request = {}
  local add_request = {}

  for _, equipment in ipairs(grid.equipment) do
    removal_request[util.positiontostr(equipment.position)] = equipment
  end

  for _, expected in ipairs(template.grid.equipment) do
    local position_str = util.positiontostr(expected.position)
    local actual = removal_request[position_str]
    if actual then
      if actual.name == expected.name and actual.quality == expected.quality then
        removal_request[position_str] = nil
        grid.cancel_removal(actual)
      else
        add_request[position_str] = expected
        if actual.name == equipment_ghost and actual.ghost_name == expected.name and actual.quality == expected.quality then
          removal_request[position_str] = nil -- keep the ghost to prevent restarting the logistic request
        end
      end
    else
      add_request[position_str] = expected
    end
  end
  
  local nearby_container = get_nearby_container(entry)
  local chest_inventory = nil;
  if nearby_container and nearby_container.valid then
    chest_inventory = nearby_container.get_inventory(defines.inventory.chest);
  end

  -- first remove all bad equipment from the grid, to avoid issues with overlapping elements
  -- then add the new equipment
  if chest_inventory and chest_inventory.valid then
    for _, equipment in pairs(removal_request) do
      if equipment.name ~= equipment_ghost and chest_inventory.insert({
          name = equipment.name,
          quality = equipment.quality,
          count = 1,
        }) == 1 then
          grid.take({ equipment = equipment })
      else
        grid.order_removal(equipment)
      end
    end

    for _, equipment in pairs(add_request) do
      if chest_inventory.remove({
          name = equipment.name,
          quality = equipment.quality,
          count = 1,
        }) == 1 then
          grid.put({
            name = equipment.name,
            quality = equipment.quality,
            position = equipment.position,
          })
      else
        grid.put({
          name = equipment.name,
          quality = equipment.quality,
          position = equipment.position,
          ghost = true,
        })
      end
    end

  else
    for _, equipment in pairs(removal_request) do
      grid.order_removal(equipment)
    end
    for _, equipment in pairs(add_request) do
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
