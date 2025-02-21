require("shared")

data:extend({
  {
    type = "string-setting",
    name = mod_prefix .. "heating-radius",
    setting_type = "startup", order = "a",
    default_value = "Directly above",
    allowed_values = {"Directly above", "Around too"},
  },
})

local underground_belts = {
  {order = "a", prefix = ""},
  {order = "b", prefix = "fast-"},
  {order = "c", prefix = "express-"},
}

if mods["space-age"] or mods["factorioplus"] then
  table.insert(underground_belts, {order = "d", prefix = "turbo-"})
end

if mods["factorioplus"] then
  table.insert(underground_belts, {order = "e", prefix = "supersonic-"})
end

for _, underground_belt in ipairs(underground_belts) do
  local item_name = underground_belt.prefix .. "underground-belt"

  data:extend({
    {
      type = "int-setting",
      name = mod_prefix .. "distance-" .. item_name,
      -- localised_name = {"", string.format("[item=%s]", item_name)},
      localised_name = {"mod-setting-name.underground-heat-pipe--distance", string.format("[item=%s]", item_name)},
      setting_type = "startup", order = "b" .. underground_belt.order,
      minimum_value = -1,
      default_value = -1,
      maximum_value = 100,
    },
  })
end
