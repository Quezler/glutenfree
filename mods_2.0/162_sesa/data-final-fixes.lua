local Shared = require("shared")

for _, resource in ipairs(Shared.resources) do
  -- postprocess forces a whitelist of tiles which the SA planets lack
  data.raw["resource"][resource.name].autoplace.tile_restriction = nil
end
