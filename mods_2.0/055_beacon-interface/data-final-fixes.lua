local shared = require("shared")

local module_category = {
  type = "module-category",
  name = mod_prefix .. "module-category",
}
data:extend{module_category}

for _, effect in ipairs(shared.effects) do
  for i = 1, 16 do
    local two_character_number = string.format("%02d", i)
    local icons = {
      {
        icon = "__beacon-interface__/graphics/icons/compilatron-module.png",
      },
      {
        icon = "__base__/graphics/icons/signal/signal_" .. string.upper(effect:sub(1, 1)) .. ".png",
        icon_size = 64,
        scale = 0.2,
        shift = {-10, 10},
      },
      {
        icon = "__base__/graphics/icons/signal/signal_" .. string.sub(two_character_number, 1, 1) .. ".png",
        icon_size = 64,
        scale = 0.2,
        shift = { 0, 10},
      },
      {
        icon = "__base__/graphics/icons/signal/signal_" .. string.sub(two_character_number, 2, 2) .. ".png",
        icon_size = 64,
        scale = 0.2,
        shift = { 10, 10},
      },
    }

    local module = {
      type = "module",
      name = string.format(mod_prefix .. "%s-module-%s", effect, two_character_number),
      icons = icons,

      order = string.format(mod_prefix .. "%s-module-%s", effect, two_character_number),
      localised_name = {"item-name." .. mod_prefix .. "module", effect, two_character_number},

      stack_size = 1,
      flags = {"not-stackable"},

      category = module_category.name,
      tier = i,
      effect = {
        [effect] = shared.module_number_to_strength[two_character_number] / 100,
      },

      auto_recycle = false,
      hidden = true,
    }

    if not feature_flags["quality"] then
      module.effect["quality"] = nil
    end

    data:extend({module})
  end
end

