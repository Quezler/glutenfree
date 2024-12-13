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
        icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon-light.png",
        tint = {0, 1, 0, 0.2},
      }
    },
    subgroup = subgroup,
    order = "g[centrifuge]-a[advanced-centrifuge]", -- Needs adjustment
    place_result = "k11-advanced-centrifuge",
    stack_size = 10,
  }
})
