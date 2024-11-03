local flib_bounding_box = require("__flib__.bounding-box")

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

local function get_tilebox(bounding_box)
  bounding_box = flib_bounding_box.ceil(bounding_box)
  local left_top = bounding_box.left_top
  local right_bottom = bounding_box.right_bottom

  local positions = {}

  for y = left_top.y, right_bottom.y - 1 do
      for x = left_top.x, right_bottom.x - 1 do
          table.insert(positions, {x = x, y = y})
      end
  end

  return positions
end

-- position is expected to have a .5 decimal
local function get_piece(position, center)
  if position.x > center.x then
    return position.y < center.y and "back_right" or "front_right"
  else
    return position.y < center.y and "back_left" or "front_left"
  end
end

-- synced with __space-age__/graphics/entity/space-platform-build-anim/entity-build-animations.lua
local frame_count = 32
local animation_speed = 0.5

script.on_event(defines.events.on_built_entity, function(event)
  if event.entity.surface.platform then return end

  for _, position in ipairs(get_tilebox(event.entity.bounding_box)) do
    position.x = position.x + 0.5
    position.y = position.y + 0.5
    local piece = get_piece(position, event.entity.position)

    rendering.draw_animation{
      target = position,
      surface = event.entity.surface,
      animation = "platform_entity_build_animations-" .. piece .. "-body",
      time_to_live = frame_count / animation_speed - 2, -- or -2?
      animation_offset = -(game.tick * animation_speed) % frame_count, -- Xorimuth @ https://discord.com/channels/1214952937613295676/1281881163702730763/1302647943576293469
    }

    rendering.draw_animation{
      target = position,
      surface = event.entity.surface,
      animation = "platform_entity_build_animations-" .. piece .. "-body",
      time_to_live = frame_count / animation_speed - 2, -- or -2?
      animation_offset = -(game.tick * animation_speed) % frame_count, -- Xorimuth @ https://discord.com/channels/1214952937613295676/1281881163702730763/1302647943576293469
    }
  end

  -- event.entity.destroy()
end)
