local subgroup = "production-machine"

if mods["space-exploration"] then

subgroup = "radiation"

end 

data:extend({
  {
    type = "item",
    name = "k11-advanced-centrifuge",
    icon = "__advanced-centrifuge__/graphics/advanced-centrifuge/advanced-centrifuge-icon.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = subgroup,
    order = "g[centrifuge]-a[advanced-centrifuge]", -- Needs adjustment
    place_result = "k11-advanced-centrifuge",
    stack_size = 50,
  }
})
