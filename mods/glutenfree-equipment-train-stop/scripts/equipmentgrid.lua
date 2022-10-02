local equipmentgrid = {}

function equipmentgrid.tick_rolling_stock(entry, entity)

  local grid = entity.grid
  if not grid then return equipmentgrid.flying_text(entry.train_stop, 'No equipment grid found.') end

  local template_inventory = entry.template_container.get_inventory(defines.inventory.chest)
  if template_inventory.is_empty() then return equipmentgrid.flying_text(entry.train_stop, 'Template chest is empty.') end

  local template = template_inventory.find_item_stack(entity.name) -- assume that the entity & item to place it are named identically
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

  print(serpent.block( grid.get_contents() ))
  -- print(serpent.block( grid.equipment ))
end

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

return equipmentgrid
