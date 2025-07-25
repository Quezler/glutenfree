data:extend({
  {
    type = "simple-entity",
    name = "se-little-inferno",
    collision_box = { { -0.75, -0.75 }, { 0.75, 0.75 } },
    selection_box = { { -0.9, -0.9 }, { 0.9, 0.9 } },
    flags = {"placeable-neutral"},
    selectable_in_game = false,
    icon = "__core__/graphics/icons/unknown.png",
    icon_size = 64,
    -- animations = util.empty_sprite(),
    animations = {
      filename = "__core__/graphics/icons/unknown.png",
      priority = "extra-high",
      width = 64,
      height = 64,
    },
    emissions_per_second = {pollution = -1000 * 1000},
    collision_mask = {layers = {}},
    hidden = true,
  }
})

-- invisible
if true then
  data.raw["simple-entity"]["se-little-inferno"].animations = util.empty_sprite()
end
