local equipmentgrid = {}

function equipmentgrid.tick_rolling_stock(entry, entity)

  local grid = entity.grid
  if not grid then return equipmentgrid.flying_text(entry.train_stop, 'No equipment grid found.') end

  local template_inventory = entry.template_container.get_inventory(defines.inventory.chest)
  if template_inventory.is_empty() then return equipmentgrid.flying_text(entry.train_stop, 'Template chest is empty.') end

  local template = template_inventory.find_item_stack(game.entity_prototypes[entity.name].items_to_place_this[1].name)
  if not template then return equipmentgrid.flying_text(entry.train_stop, 'Missing template for '.. string.gsub(entity.name, '%-', ' ') ..'.') end
  if not template.grid then return equipmentgrid.flying_text(entry.train_stop, 'Template equipment grid empty.') end

  -- {
  --   ["imersite-solar-panel-equipment"] = 1
  -- }
  -- print(serpent.block( template.grid.get_contents() ))

  -- {
  --   ["advanced-additional-engine"] = 6,
  --   ["big-battery-equipment"] = 5,
  --   ["big-imersite-solar-panel-equipment"] = 5,
  --   ["energy-shield-equipment"] = 1,
  --   ["personal-laser-defense-mk2-equipment"] = 1
  -- }
  local contents = grid.get_contents()
  -- print(serpent.block( contents ))

  local template_contents = template.grid.get_contents()
  if equipmentgrid.contents_are_equal(template_contents, contents) then return end

  local network = entry.train_stop.surface.find_logistic_network_by_position(entry.template_container.position, entry.train_stop.force)
  if not network then return equipmentgrid.flying_text(entry.train_stop, 'Template chest needs logistic coverage.') end

  -- game.print('i should update this grid')

  -- todo: currently does not return what is missing
  if not equipmentgrid.logistic_network_has_contents(network, template_contents) then
    return equipmentgrid.flying_text(entry.train_stop, 'Logistic network is lacking one or more items.')
  end

  -- dump the entire current grid on the ground, we're gonna fill it from scratch
  equipmentgrid.spill_rolling_stock_grid(entity)

  -- teleport the items over from the logistic network one-by-one and insert it
  for _, equipment in ipairs(template.grid.equipment) do
    network.remove_item({name = equipment.name, count = 1})
    grid.put({
      name = equipment.name,
      position = equipment.position
    })
  end
end

-- this does not care about the position inside
function equipmentgrid.contents_are_equal(a, b)
  if table_size(a) ~= table_size(b) then return false end

  for item, count in pairs(a) do
    if b[item] == nil then return false end
    if b[item] ~= count then return false end
  end

  return true
end

function equipmentgrid.flying_text(entity, text)
  entity.surface.create_entity{name = "flying-text", position = entity.position, text = text}
end

-- does the logistic network has equal or more of each of the requested contents?
function equipmentgrid.logistic_network_has_contents(logistic_network, contents)
  local items = logistic_network.get_contents()

  for name, count in pairs(contents) do
    if items[name] == nil then return false end
    if items[name] < count then return false end
  end

  return true
end

function equipmentgrid.spill_rolling_stock_grid(entity)
  for item, count in pairs(entity.grid.take_all()) do
    local stack = {name = item, count = count}
    entity.surface.spill_item_stack(entity.position, stack, false, entity.force, false)
  end
end

return equipmentgrid
