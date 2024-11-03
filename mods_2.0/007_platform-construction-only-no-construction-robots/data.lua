local construction_robot = data.raw["construction-robot"]["construction-robot"]

local function turn_construction_robots_invisible()
  construction_robot.idle = util.empty_sprite()
  -- construction_robot.idle_with_cargo = util.empty_sprite()
  construction_robot.in_motion = util.empty_sprite()
  -- construction_robot.in_motion_with_cargo = util.empty_sprite()
  construction_robot.shadow_idle = util.empty_sprite()
  -- construction_robot.shadow_idle_with_cargo = util.empty_sprite()
  construction_robot.shadow_in_motion = util.empty_sprite()
  -- construction_robot.shadow_in_motion_with_cargo = util.empty_sprite()
  construction_robot.working = util.empty_sprite()
  construction_robot.shadow_working = util.empty_sprite()
end

-- turn_construction_robots_invisible()

data.raw["roboport"]["roboport"].radar_range = 2
data.raw["roboport"]["roboport"].construction_radius = 1000000
