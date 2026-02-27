local Shared = require("shared")

for _, resource in ipairs(Shared.resources) do
  -- postprocess forces a whitelist of tiles which the SA planets lack
  data.raw["resource"][resource.name].autoplace.tile_restriction = nil
end

for _, resource in pairs(data.raw["resource"]) do
  -- scream test for good measure and stuff like coal on SA planets
  if resource.autoplace then
    resource.autoplace.tile_restriction = nil
  end
end

-- SESA rockets are apparently around 4 times more expensive than SA rockets according to:
-- https://discord.com/channels/419526714721566720/1473279418142298164/1475269441691586561
data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required = 25
data.raw["rocket-silo"]["sa-rocket-silo"].rocket_parts_required = 25

-- restore after mods/space-exploration/prototypes/phase-3/resources.lua touched it
data.raw["resource"]["scrap"].autoplace = sesa_scrap_autoplace
