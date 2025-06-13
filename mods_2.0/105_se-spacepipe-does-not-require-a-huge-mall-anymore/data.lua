local map = {
  ["se-space-pipe-long-j-3" ] = 2,
  ["se-space-pipe-long-j-5" ] = 3,
  ["se-space-pipe-long-j-7" ] = 4,
  ["se-space-pipe-long-s-9" ] = 5,
  ["se-space-pipe-long-s-15"] = 8,
}

for name, count in pairs(map) do
  if data.raw["storage-tank"][name].placeable_by then
    error("did not expect `placeable_by` for the `"..name.."` to be defined.")
  end
  data.raw["storage-tank"][name].placeable_by = {item = "se-space-pipe", count = count}

  if data.raw["storage-tank"][name].minable.results then
    error("did not expect `minable.results` for the `"..name.."` to be defined.")
  end
  data.raw["storage-tank"][name].minable.results = {{type = "item", name = "se-space-pipe", amount = count}}

  -- data.raw["item"][name].place_result = nil
end

-- if data.raw["item"]["se-space-pipe"].flags == nil then data.raw["item"]["se-space-pipe"].flags = {} end
-- table.insert(data.raw["item"]["se-space-pipe"].flags, "primary-place-result")
