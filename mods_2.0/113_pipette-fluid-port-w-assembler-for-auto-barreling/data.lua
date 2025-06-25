data:extend({
  {
    type = "simple-entity",
    name = "pipe-connection",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    flags = {"placeable-neutral"},
    icon = "__base__/graphics/icons/fluid/barreling/empty-barrel.png",
    animations = util.empty_sprite(),
    collision_mask = {layers = {}},
    minable = {mining_time = 10}, -- to have the selection box orange and not red
    selection_priority = 51,
    placeable_by = {item = "barrel", count = 1}, -- todo: invisible item
  }
})
