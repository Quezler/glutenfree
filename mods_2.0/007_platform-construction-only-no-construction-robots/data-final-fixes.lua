local construction_robot = data.raw["construction-robot"]["construction-robot"]

local function turn_construction_robots_invisible()
  construction_robot.idle = nil
  construction_robot.in_motion = nil
  construction_robot.shadow_idle = nil
  construction_robot.shadow_in_motion = nil
  construction_robot.working = nil
  construction_robot.shadow_working = nil

  construction_robot.sparks = nil
  construction_robot.smoke = nil
end

turn_construction_robots_invisible()
construction_robot.icon_draw_specification = {scale = 0}
construction_robot.quality_indicator_scale = 0
construction_robot.selectable_in_game = false
construction_robot.speed = 10
construction_robot.energy_per_move = nil
construction_robot.energy_per_tick = nil

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

assert(construction_robot.created_effect == nil, serpent.block(construction_robot.created_effect))
construction_robot.created_effect = created_effect
