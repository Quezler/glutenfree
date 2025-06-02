-- a list of prototypes where an undefined icon_draw_specification makes alt mode look ugly:
local prototype_types = {
  "loader",
  "loader-1x1",
  "splitter",
  "container",
  "logistic-container",
}

for _, prototype_type in ipairs(prototype_types) do
  for _, prototype in pairs(data.raw[prototype_type]) do
    if prototype.icon_draw_specification == nil then
      log(prototype.name)
    end
  end
end
