local function places_storage_tank(item)
  -- todo: check placeable_by on storage tank prototypes and place_result on every item instead of using a hardcoded list
  return item.name == 'storage-tank'
end

for _, item in pairs(data.raw['item']) do
  if places_storage_tank(item) then
    item.type = 'item-with-tags'
    data:extend{item}
    data.raw['item'][item.name] = nil
  end
end
