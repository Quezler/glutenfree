-- copy before mods/space-exploration/prototypes/phase-3/resources.lua touches it
sesa_scrap_autoplace = data.raw["resource"]["scrap"].autoplace

-- add all module recipes to the electromagnetic plant.
-- is it overpowered? yeah quite possibly, especially for the late game modules.
-- but note that their ingredients have to come down from space so it makes some sense.
local module_util = require("__space-exploration__/prototypes/phase-multi/module-util")
for _, name in pairs({"speed", "efficiency", "productivity", "quality"}) do
  for tier = 1, 9 do
    local recipe = data.raw["recipe"][module_util.module_name(name .. "-module", tier)]
    if recipe then
      recipe.additional_categories = recipe.additional_categories or {}
      table.insert(recipe.additional_categories, "electromagnetics")
    end
  end
end
