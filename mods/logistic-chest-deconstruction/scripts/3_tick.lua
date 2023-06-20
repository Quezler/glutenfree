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

function Handler.on_nth_tick_300(event) -- defines.alert_type.no_storage times out after 5 seconds
  for unit_number, storage_chest in pairs(global.no_storage_alerts) do
    if storage_chest.valid == false or storage_chest.get_inventory(defines.inventory.chest).can_insert({name = "deconstruction-planner"}) then
      global.no_storage_alerts[unit_number] = nil
    else
      for _, player in pairs(storage_chest.force.connected_players) do
        player.add_alert(storage_chest, defines.alert_type.no_storage)
      end
    end
  end
end
