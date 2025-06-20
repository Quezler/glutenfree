local platform_proxy = data.raw["proxy-container"][mod_prefix .. "platform-cargo-bay-proxy"]
local planet_proxy = data.raw["proxy-container"][mod_prefix .. "planet-cargo-bay-proxy"]

local should_copy_flag = {
  ["no-automated-item-insertion"] = true,
  ["no-automated-item-removal"] = true,
}

for _, flag in ipairs(data.raw["space-platform-hub"]["space-platform-hub"].flags or {}) do
  if should_copy_flag[flag] then
    table.insert(platform_proxy.flags, flag)
  end
end

for _, flag in ipairs(data.raw["cargo-landing-pad"]["cargo-landing-pad"].flags or {}) do
  if should_copy_flag[flag] then
    table.insert(planet_proxy.flags, flag)
  end
end
