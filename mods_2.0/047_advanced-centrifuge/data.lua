require("prototypes/entities/buildings/advanced-centrifuge")
require("prototypes/items/buildings")
require("prototypes/recipes/buildings")
require("prototypes/technologies/buildings")

local remove_green_tint_from_icons = mods["space-exploration"] ~= nil
-- remove_green_tint_from_icons = true

if remove_green_tint_from_icons then
  data.raw["item"              ]["k11-advanced-centrifuge"].icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-base.png"
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-base.png"
  data.raw["technology"        ]["k11-advanced-centrifuge"].icons = {
    {
      icon = util.empty_sprite().filename,
      icon_size = 1,
    },
    {
      icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-tech-icon-base.png",
      icon_size = 256,
      shift = {0, -10},
    }
  }
end

if mods["space-age"] then
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].heating_energy = "200kW"
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].graphics_set.reset_animation_when_frozen = true
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].graphics_set.frozen_patch = {
    filename = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-frozen.png",
    priority = "high",
    width = 450,
    height = 550,
    shift = { 0, -0.9 },
    scale = 0.5
  }

  table.insert(data.raw["technology"]["k11-advanced-centrifuge"].unit.ingredients, {"space-science-pack", 1})
end

if settings.startup["k11-advanced-centrifuge-base-productivity"].value then
  data.raw["assembling-machine"]["k11-advanced-centrifuge"].effect_receiver = { base_effect = { productivity = 0.5 }}
end
