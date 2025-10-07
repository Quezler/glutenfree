-- weird, data-updates.lua is required since SE doesn't define the new module tiers in data.lua?

local module_types = {"speed", "productivity", "efficiency"}

if settings.startup["se-enable-data-stage-quality-mod-compatibility"].value then
  table.insert(module_types, "quality")
end

for _, variant in ipairs(module_types) do
  for i = 1, 9 do
    local name = variant .. "-module"
    if i ~= 1 then name = name .. "-" .. i end
    local prototype = data.raw["module"][name]
    assert(prototype, name)
    prototype.icons = {
      {
        icon = prototype.icon,
      },
      {
        icon = "__space-exploration-graphics__/graphics/icons/number/" .. i .. ".png",
        scale = 0.5,
        shift = {-10, -10},
        icon_size = 20
      }
    }
  end
end
