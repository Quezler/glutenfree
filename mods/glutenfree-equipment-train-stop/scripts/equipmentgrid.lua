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

  -- local network = entry.train_stop.surface.find_logistic_network_by_position(entry.template_container.position, entry.train_stop.force)
  -- if not network then return equipmentgrid.flying_text(entry.train_stop, 'Template chest needs logistic coverage.') end

  -- game.print('i should update this grid')

  -- todo: currently does not return what is missing

  if not equipmentgrid.contents_a_has_contents_b(template_inventory.get_contents(), template_contents) then
    local proxy = entry.template_container.surface.find_entity('item-request-proxy', entry.template_container.position)

    if proxy then
      proxy.item_requests = template_contents
    else
      entity.surface.create_entity({
        name = "item-request-proxy",
        target = entry.template_container,
        modules = template_contents,
        position = entity.position,
        force = entity.force,
      })
    end

    return equipmentgrid.flying_text(entry.train_stop, 'Template chest is lacking one or more items.')
  end

  -- dump the entire current grid on the ground, we're gonna fill it from scratch
  equipmentgrid.spill_rolling_stock_grid_if_not_fit_into(entity, template_inventory)

  -- teleport the items over from the logistic network one-by-one and insert it
  for _, equipment in ipairs(template.grid.equipment) do
    template_inventory.remove({name = equipment.name, count = 1})
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
function equipmentgrid.contents_a_has_contents_b(contents_a, contents_b)
  for name, count in pairs(contents_b) do
    if contents_a[name] == nil then return false end
    if contents_a[name] < count then return false end
  end

  return true
end

function equipmentgrid.spill_rolling_stock_grid_if_not_fit_into(entity, inventory)
  for item, count in pairs(entity.grid.take_all()) do
    local stack = {name = item, count = count}

    local inserted = inventory.insert(stack)
    stack.count = stack.count - inserted

    if stack.count > 0 then
      entity.surface.spill_item_stack(entity.position, stack, false, entity.force, false)
    end
  end
end

return equipmentgrid
