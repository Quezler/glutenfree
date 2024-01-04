data:extend({
  {
    type = "simple-entity",
    name = "pipe-connection",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    flags = {"placeable-neutral"},
    icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
    icon_size = 64,
    animations = util.empty_sprite(),
    collision_mask = {},
    minable = {mining_time = 10}, -- to have the selection box orange and not red
    selection_priority = 51,
    placeable_by = {item = 'empty-barrel', count = 1}, -- todo: invisible item
  }
})
