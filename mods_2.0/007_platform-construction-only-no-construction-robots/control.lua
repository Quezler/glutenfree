local type_to_string = {}
for k, v in pairs(defines.robot_order_type) do
  type_to_string[v] = k
end

script.on_event(defines.events.on_tick, function(event)
  local logistic_networks = game.forces["player"].logistic_networks["nauvis"] or {}

  for _, logistic_network in ipairs(logistic_networks) do
    for _, construction_robot in ipairs(logistic_network.construction_robots) do
      local robot_order_queue = construction_robot.robot_order_queue

      for _, worker_robot_order in ipairs(robot_order_queue) do
        worker_robot_order.type_human = type_to_string[worker_robot_order.type]
      end

      local current_order = robot_order_queue[1]
      if current_order and current_order.target then -- target can sometimes be optional
        -- todo: construction robots sleep when there is no enemy around, pr or spawn invisible biters?
        -- looks like ->activeNeighbourForcesSet/show-active-forces-around debug is rather generous btw
        assert(construction_robot.teleport(current_order.target.position))
      end

      log(serpent.block( robot_order_queue ))
    end
  end
end)
