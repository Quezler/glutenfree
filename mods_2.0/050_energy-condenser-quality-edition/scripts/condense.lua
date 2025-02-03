local Condense = {}

local next_quality_name = {} -- next_quality_name["normal"] = "uncommon"
local is_quality_before = {} -- if is_quality_before["legendary"]["uncommon"] then (yes, uncommon eventually leads to legendary)

for _, quality in pairs(prototypes.quality) do
  if quality.next then
    next_quality_name[quality.name] = quality.next.name
  end
  is_quality_before[quality.name] = {}
end

for _, quality in pairs(prototypes.quality) do
  local parent = quality.next
  while parent do
    is_quality_before[parent.name][quality.name] = true
    parent = parent.next
  end
end

-- log(serpent.block(next_quality_name))
-- log(serpent.block(is_quality_before))

function Condense.trigger(struct)
end

return Condense
