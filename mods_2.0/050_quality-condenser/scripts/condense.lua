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

local function get_spoil_percentage(inventory, item)
  local spoil_percentage = nil

  for slot = 1, #inventory do
    local stack = inventory[slot]
    if stack.valid_for_read and stack.name == item.name then
      if spoil_percentage == nil then
        spoil_percentage = stack.spoil_percent
      else
        spoil_percentage = (spoil_percentage + stack.spoil_percent) / 2
      end
    end
  end

  return spoil_percentage
end

function Condense.trigger(struct)
  local target_quality = ensure_recipe_is_set(struct.entity)
  local quality_points = math.floor(math.min((struct.entity.effects["quality"] or 0) * 1000 * target_quality.next_probability, 1000) + 0.5) -- 0-1000

  for _, item in ipairs(struct.container_inventory.get_contents()) do
    local next_quality_name = get_next_quality_name[item.quality]
    if next_quality_name and struct.entity.force.is_quality_unlocked(next_quality_name) then
      if target_quality.name == "normal" or is_quality_grandchild[target_quality.name][item.quality] then

        local number = quality_points * item.count / 1000
        local integer = math.floor(number)
        local decimal = number - integer

        if integer > 0 then
          -- any leftover points? leave that to chance :)
          if decimal > 0 and math.random() < decimal then
            integer = integer + 1
          end

          log(string.format("%d x %s (%s) x %d%% = %d (%d + %f)", item.count, item.name, item.quality, quality_points / 10, integer, number, decimal))

          local to_insert = {name = item.name, count = integer, quality = next_quality_name}
          if item_can_spoil[item.name] then
            to_insert["spoil_percent"] = assert(get_spoil_percentage(struct.container_inventory, item))
          end

          assert(struct.container_inventory.remove(item) == item.count) -- all items are consumed, this way there is always space.

          local inserted = struct.container_inventory.insert(to_insert)
          if inserted ~= to_insert.count then
            struct.container_inventory.sort_and_merge()
            to_insert.count = to_insert.count - inserted
            inserted = struct.container_inventory.insert(to_insert)
            assert(inserted == to_insert.count, string.format("inserted only %d of %d %s (%s)", inserted, to_insert.count, item.name, item.quality))
          end

        end
      end
    end
  end
end

return Condense
