local subgroup = "production-machine"

if mods["space-exploration"] then
  subgroup = "radiation"
end

data:extend({
  {
    type = "item",
    name = "k11-advanced-centrifuge",
    icons = {
      {
        icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-base.png",
      },
      {
        icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-mask.png",
      },
      {
        icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-mask.png",
        tint = {0, 0.75, 0, 1},
      }
    },
    subgroup = subgroup,
    order = "g[centrifuge]-a[advanced-centrifuge]", -- Needs adjustment
    place_result = "k11-advanced-centrifuge",
    stack_size = 10,
  }
})

data.raw["item"]["centrifuge"].icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon.png"
