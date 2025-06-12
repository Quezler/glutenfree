local Crafter = {}

local function add_contents_to_map(contents, map)
  for _, content in ipairs(contents) do
    local key = assert(content.quality) .. " " .. content.name
    local mapped = map[key]
    if mapped then
      mapped.count = mapped.count + content.count
    else
      map[key] = {
        name = content.name,
        quality = content.quality,
        count = content.count,
      }
    end
  end
end

-- returns true if map a had all of map b
local function map_subtract(map_a, map_b)
  for key, item_b in pairs(map_b) do
    local item_a = map_a[key]
    if not item_a then return end

    item_a.count = item_a.count - item_b.count
    if 0 > item_a.count then return end
  end

  return true
end

Crafter.craft = function(building)
  local factory = storage.factories[building.factory_index]

  local contents_map = {}
  add_contents_to_map(building.inventory.get_contents(), contents_map)
  -- log(serpent.block(contents_map))

  local buildings_map = {}
  add_contents_to_map(factory.export.entities, buildings_map)
  add_contents_to_map(factory.export.modules, buildings_map)
  -- log(serpent.block(buildings_map))

  -- circuits only trigger this method when all item requests are fulfilled,
  -- but we do have to confirm everything is here, we'll start with the buildings:
  -- (we're also subtracting them from the contents to avoid using them as ingredients)
  if not map_subtract(contents_map, buildings_map) then return end

  log("crafting")
end

return Crafter
