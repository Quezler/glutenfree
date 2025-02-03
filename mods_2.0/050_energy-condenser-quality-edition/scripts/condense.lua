local Condense = {}

local get_next_quality_name = {} -- next_quality_name["normal"] = "uncommon"
local is_quality_grandchild = {} -- if is_quality_grandchild["legendary"]["uncommon"] then (uncommon eventually leads to legendary)

for _, quality in pairs(prototypes.quality) do
  if quality.next then
    get_next_quality_name[quality.name] = quality.next.name
  end
  is_quality_grandchild[quality.name] = {}
end

for _, quality in pairs(prototypes.quality) do
  local parent = quality.next
  while parent do
    is_quality_grandchild[parent.name][quality.name] = true
    parent = parent.next
  end
end

-- log(serpent.block(next_quality_name))
-- log(serpent.block(is_quality_before))

local item_can_spoil = {}
for _, item in pairs(prototypes.item) do
  if item.get_spoil_ticks() > 0 then
    item_can_spoil[item.name] = true
  end
end

local function populate_spoil_percentages(inventory)
  local spoil_percentages = {}

  for slot = 1, #inventory do
    local item = inventory[slot]
    if item.valid_for_read and item_can_spoil[item.name] then
      local key = item.quality.name .. "-" .. item.name
      if spoil_percentages[key] then
        spoil_percentages[key] = (spoil_percentages[key] + item.spoil_percent) / 2
      else
        spoil_percentages[key] = item.spoil_percent
      end
    end
  end

  return spoil_percentages
end

function Condense.trigger(struct)
  local target_quality = ensure_recipe_is_set(struct.entity).name
  local quality_points = math.floor(math.min((struct.entity.effects["quality"] or 0) * 100) + 0.5) -- 0-1000

  local spoil_percentages = nil

  for _, item in ipairs(struct.container_inventory.get_contents()) do
    local next_quality_name = get_next_quality_name[item.quality]
    if next_quality_name and struct.entity.force.is_quality_unlocked(next_quality_name) then
      if target_quality == "normal" or is_quality_grandchild[target_quality][item.quality] then

        local number = quality_points * item.count / 1000
        local integer = math.floor(number)
        local decimal = number - integer

        -- any leftover points? leave that to chance :)
        if decimal > 0 and math.random() < decimal then
          integer = integer + 1
        end

        log(string.format("%d x %s (%s) x %d%% = %d (%d + %f)", item.count, item.name, item.quality, quality_points / 10, integer, number, decimal))

        local to_insert = {name = item.name, count = integer, quality = next_quality_name}
        if item_can_spoil then
          if spoil_percentages == nil then
            spoil_percentages = populate_spoil_percentages(struct.container_inventory)
          end
          to_insert["spoil_percent"] = assert(spoil_percentages[item.quality .. "-" .. item.name])
        end

        struct.container_inventory.remove(item) -- all items are consumed, this way there is always space.
        struct.container_inventory.insert(to_insert)
      end
    end
  end
end

return Condense
