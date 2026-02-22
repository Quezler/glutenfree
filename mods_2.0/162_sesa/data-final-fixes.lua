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
