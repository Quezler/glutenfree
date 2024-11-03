script.on_event(defines.events.on_tick, function(event)
  local logistic_networks = game.forces["player"].logistic_networks["nauvis"] or {}

  for _, logistic_network in ipairs(logistic_networks) do
    for _, construction_robot in ipairs(logistic_network.construction_robots) do
      local robot_order = construction_robot.robot_order_queue[1]

      if robot_order and robot_order.target then -- target can sometimes be optional
        -- todo: construction robots sleep when there is no enemy around, pr or spawn invisible biters?
        -- looks like ->activeNeighbourForcesSet/show-active-forces-around debug is rather generous btw
        assert(construction_robot.teleport(robot_order.target.position))
      end
    end
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  rendering.draw_animation{
    target = {entity = event.entity, offset = {0, -2}},
    surface = event.entity.surface,
    animation = "platform_entity_build_animations-front_left-top",
    time_to_live = 32 * 2,
    animation_offset = 0,
  }

  -- rendering.draw_animation{
  --   target = event.entity.position,
  --   surface = event.entity.surface,
  --   animation = "platform_entity_build_animations-front_left-body",
  --   time_to_live = 32 * 2,
  -- }
end)
