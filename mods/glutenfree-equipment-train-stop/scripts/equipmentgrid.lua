local equipmentgrid = {}

function equipmentgrid.tick_rolling_stock(entity)

  local grid = entity.grid
  if not grid then return end -- does the player not have a mod installed that adds equipment grids to rolling stock?

  local template = '?'

  -- {
  --   ["advanced-additional-engine"] = 6,
  --   ["big-battery-equipment"] = 5,
  --   ["big-imersite-solar-panel-equipment"] = 5,
  --   ["energy-shield-equipment"] = 1,
  --   ["personal-laser-defense-mk2-equipment"] = 1
  -- }
  local contents = grid.get_contents()

  print(serpent.block( grid.get_contents() ))
  print(serpent.block( grid.equipment ))
end

function equipmentgrid.contents_are_equal(a, b)
  if table_size(a) ~= table_size(b) then return false end

  for item, count in pairs(a) do
    if b[item] == nil then return false end
    if b[item] ~= count then return false end
  end

  return true
end

return equipmentgrid
