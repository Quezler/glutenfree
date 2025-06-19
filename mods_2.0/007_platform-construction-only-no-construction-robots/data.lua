-- borrowed from the ghosts-do-not-kick-you-out-of-their-gui mod
data:extend{{
  type = "simple-entity",
  name = "ghost-being-constructed",
  icon = "__core__/graphics/icons/mip/ghost-entity.png",

  flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},

  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
  selection_box = {{-0.1, -0.1}, {0.1, 0.1}},

  minable = {mining_time = 1},
  selectable_in_game = false,
  hidden = true,
}}
