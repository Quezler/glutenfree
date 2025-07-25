require("namespace")
local minimum_resource_patch_search_radius = settings.startup[mod_prefix .. "minimum-resource-patch-search-radius"].value --[[@as number]]

for _, resource in pairs(data.raw["resource"]) do
  if not resource.hidden then
    local old_resource_patch_search_radius = resource.resource_patch_search_radius or 3
    local new_resource_patch_search_radius = math.max(minimum_resource_patch_search_radius, old_resource_patch_search_radius)

    if new_resource_patch_search_radius ~= old_resource_patch_search_radius then
      resource.resource_patch_search_radius = new_resource_patch_search_radius
      log(string.format("%s (%d -> %d)", resource.name, old_resource_patch_search_radius, new_resource_patch_search_radius))
    end
  end
  resource.hidden = true
end
