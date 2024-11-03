local flib_bounding_box = require("__flib__.bounding-box")

script.on_init(function()
  storage.entities_being_built = {}
end)

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

local function is_back_piece(piece)
  return piece == "back_left" or piece == "back_right"
end

local function get_manhattan_distance(position, center)
  local delta_x = position.x - center.x
  local delta_y = position.y - center.y

  return math.abs(delta_x) + math.abs(delta_y)
end

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity

  if entity.surface.platform then return end
  if entity.name == "entity-ghost" then return end
  if entity.name == "tile-ghost" then return end

  local surface = entity.surface

  local entity_being_built = {
    entity = event.entity,

    animations = {},
  }

  for _, position in ipairs(get_tilebox(entity.bounding_box)) do
    position.x = position.x + 0.5
    position.y = position.y + 0.5
    local piece = get_piece(position, entity.position)

    local manhattan_distance = get_manhattan_distance(position, entity.position)
    manhattan_distance = manhattan_distance * 8 -- frames between building

    local top = rendering.draw_animation{
      target = position,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-top",
      time_to_live = 60 * 10,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = "higher-object-above",
    }

    local body = rendering.draw_animation{
      target = position,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-body",
      time_to_live = 60 * 10,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = is_back_piece(piece) and "lower-object-above-shadow" or "object",
    }

    table.insert(entity_being_built.animations, {
      top = top,
      body = body,
      animation_offset_at_tick = {
        [event.tick + manhattan_distance + 1] = 1,
        [event.tick + manhattan_distance + 4] = 2,
        [event.tick + manhattan_distance + 6] = 3,
        [event.tick + manhattan_distance + 8] = 4,
        [event.tick + manhattan_distance + 10] = 5,
        [event.tick + manhattan_distance + 12] = 6,
        [event.tick + manhattan_distance + 14] = 7,
        [event.tick + manhattan_distance + 16] = 8,
        [event.tick + manhattan_distance + 18] = 9,
        [event.tick + manhattan_distance + 20] = 10,
        [event.tick + manhattan_distance + 22] = 11,
        [event.tick + manhattan_distance + 24] = 12,
        [event.tick + manhattan_distance + 26] = 13,
        [event.tick + manhattan_distance + 28] = 14,
      }
    })
  end

  assert(entity.unit_number)
  storage.entities_being_built[entity.unit_number] = entity_being_built
end)

script.on_event(defines.events.on_tick, function(event)
  for _, entity_being_built in pairs(storage.entities_being_built) do
    for _, animation in ipairs(entity_being_built.animations) do
      local animation_offset = animation.animation_offset_at_tick[event.tick]
      if animation_offset ~= nil then
        animation.top.animation_offset = animation_offset
        animation.body.animation_offset = animation_offset
      end
    end
  end
end)
