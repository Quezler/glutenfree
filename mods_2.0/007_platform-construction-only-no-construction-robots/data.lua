local space_platform_entity_build_animations = require("__space-age__/graphics/entity/space-platform-build-anim/entity-build-animations")

local function make_animation_prototype(a, b)
  local animation = table.deepcopy(space_platform_entity_build_animations[a][b])
  animation.type = "animation"
  animation.name = string.format("platform_entity_build_animations-%s-%s", a, b)
  data:extend{animation}
end

make_animation_prototype("back_left", "top")
make_animation_prototype("back_left", "body")

make_animation_prototype("back_right", "top")
make_animation_prototype("back_right", "body")

make_animation_prototype("front_left", "top")
make_animation_prototype("front_left", "body")

make_animation_prototype("front_right", "top")
make_animation_prototype("front_right", "body")

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
