local construction_robot = data.raw["construction-robot"]["construction-robot"]

local function turn_construction_robots_invisible()
  construction_robot.idle = util.empty_sprite()
  -- construction_robot.idle_with_cargo = util.empty_sprite() -- logistic robot only
  construction_robot.in_motion = util.empty_sprite()
  -- construction_robot.in_motion_with_cargo = util.empty_sprite() -- logistic robot only
  construction_robot.shadow_idle = util.empty_sprite()
  -- construction_robot.shadow_idle_with_cargo = util.empty_sprite() -- logistic robot only
  construction_robot.shadow_in_motion = util.empty_sprite()
  -- construction_robot.shadow_in_motion_with_cargo = util.empty_sprite() -- logistic robot only
  construction_robot.working = util.empty_sprite()
  construction_robot.shadow_working = util.empty_sprite()
end

turn_construction_robots_invisible()
construction_robot.icon_draw_specification = {scale = 0}
construction_robot.selectable_in_game = false

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

local created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "construction-robot-created",
      },
    }
  }
}

local construction_robot = data.raw["construction-robot"]["construction-robot"]
assert(construction_robot.created_effect == nil)
construction_robot.created_effect = created_effect

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
