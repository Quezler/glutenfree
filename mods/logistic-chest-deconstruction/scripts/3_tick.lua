function Handler.on_robot_pre_mined(event)
  table.insert(global.construction_robots, event.robot)
end

function Handler.on_tick(event)
  for _, construction_robot in ipairs(global.construction_robots) do
    Handler.on_robot_post_mined(construction_robot)
  end
  global.construction_robots = {}

  local robots_to_check = global.robots_to_check_at_tick[event.tick]
  if robots_to_check then global.robots_to_check_at_tick[event.tick] = nil
    for _, robot_task in ipairs(robots_to_check) do
      if robot_task.robot.valid then
        Handler.tick_construction_robot(robot_task)
      end
    end
  end
end

function Handler.check_robot_at_tick(robot_task, tick)
  if not global.robots_to_check_at_tick[tick] then global.robots_to_check_at_tick[tick] = {} end
  global.robots_to_check_at_tick[tick][#global.robots_to_check_at_tick[tick] + 1] = robot_task
end
