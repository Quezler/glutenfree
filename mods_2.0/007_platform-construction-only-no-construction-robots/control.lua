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

-- synced with __space-age__/graphics/entity/space-platform-build-anim/entity-build-animations.lua
local frame_count = 32
local animation_speed = 0.5

script.on_event(defines.events.on_built_entity, function(event)
  rendering.draw_animation{
    target = {entity = event.entity, offset = {0, -2}},
    surface = event.entity.surface,
    animation = "platform_entity_build_animations-front_left-body",
    time_to_live = frame_count / animation_speed - 1, -- or -2?
    animation_offset = -(game.tick * animation_speed) % frame_count, -- Xorimuth @ https://discord.com/channels/1214952937613295676/1281881163702730763/1302647943576293469
  }

  rendering.draw_animation{
    target = {entity = event.entity, offset = {0, -2}},
    surface = event.entity.surface,
    animation = "platform_entity_build_animations-front_left-body",
    time_to_live = frame_count / animation_speed - 1, -- or -2?
    animation_offset = -(game.tick * animation_speed) % frame_count, -- Xorimuth @ https://discord.com/channels/1214952937613295676/1281881163702730763/1302647943576293469
  }
end)
