require("util")

local blacklisted_names = util.list_to_map({
  "heating-tower",
})

local blacklisted_types = util.list_to_map({
  "legacy-curved-rail",
  "legacy-straight-rail",

  "train-stop",
  "rail-signal",

  "straight-rail",
  "curved-rail-a",
  "curved-rail-b",
  "half-diagonal-rail",

  "rail-ramp",
  "rail-support",
  "elevated-straight-rail",
  "elevated-curved-rail-a",
  "elevated-curved-rail-b",
  "elevated-half-diagonal-rail",

  "car",
  "spider-vehicle",
  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",

  "electric-pole",
  "lightning-attractor",
  "agricultural-tower",
})

for _, entity in pairs(prototypes.entity) do
  if blacklisted_types[entity.type] then
    blacklisted_names[entity.name] = true
  end
end

return blacklisted_names
