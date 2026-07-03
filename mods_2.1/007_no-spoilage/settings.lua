local shared = require("shared")

for _, item in ipairs(shared.spoils) do
  data:extend({
    {
        type = "bool-setting",
        name = "no-spoilage-item-" .. item.name,
        setting_type = "startup",
        default_value = item.default, -- true/checked == disable spoilage, false/unchecked = allow spoilage

        -- localised_name = {"setting-name.no-spoilage-item", {"item-name." .. item.name}},
        localised_name = {"item-name." .. item.name},
    },
  })
end
