local whitelist_if_name_matches = {
  --
}

local whitelist_if_name_contains = {
  -- nauvis
  "%-rock",
  -- vulcanus
  "vulcanus%-chimney",
  "%-demolisher%-corpse",
  -- gleba
  "%-stromatolite",
  "%-stomper%-shell",
  -- fulgora
  "fulgoran%-ruin%-",
  "fulgora%-sunk%-ruin%-",
  "fulgurite",
  -- aquilo
  "lithium%-iceberg%-",
  -- alien biomes
  "rock%-",
}

local function should_whitelist(prototype)
  if prototype.parameter then
    return false
  end

  for _, string in ipairs(whitelist_if_name_matches) do
    if prototype.name == string then
      return true
    end
  end

  for _, substring in ipairs(whitelist_if_name_contains) do
    if string.find(prototype.name, substring) then
      return true
    end
  end

  -- space exploration
  if prototype.localised_name and prototype.localised_name[1] and prototype.localised_name[1] == "entity-name.meteorite" then
    return true
  end

  return false
end

local whitelisted_names = {}
local blacklisted_names = {}
for _, prototype in pairs(data.raw["simple-entity"]) do
  if should_whitelist(prototype) then
    whitelisted_names[prototype.name] = true
    prototype.healing_per_tick = 0.01
  else
    blacklisted_names[prototype.name] = true
  end
end
log("whitelisted_names: " .. serpent.block(whitelisted_names))
log("blacklisted_names: " .. serpent.block(blacklisted_names))
