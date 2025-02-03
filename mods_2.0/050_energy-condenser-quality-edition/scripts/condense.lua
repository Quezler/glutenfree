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

function Condense.trigger(struct)
  local target_quality = ensure_recipe_is_set(struct.entity).name
  local quality_points = math.min((struct.entity.effects["quality"] or 0) * 100) -- 0-1000

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

        struct.container_inventory.remove(item) -- all items are consumed, this way there is always space.
        struct.container_inventory.insert({name = item.name, count = integer, quality = next_quality_name})
      end
    end
  end
  game.print(serpent.block( struct.container_inventory.get_contents() ))
end

return Condense
