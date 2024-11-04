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

local TICKS_PER_FRAME = 2
local FRAMES_BEFORE_BUILT = 16
local FRAMES_BETWEEN_BUILDING = 8
local FRAMES_BETWEEN_REMOVING = 4

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

  local tilebox = get_tilebox(entity.bounding_box)
  local largest_manhattan_distance = 0
  for _, position in ipairs(tilebox) do
    position.center = {x = position.x + 0.5, y = position.y + 0.5}
    position.manhattan_distance = get_manhattan_distance(position.center, entity.position)

    if position.manhattan_distance > largest_manhattan_distance then
      largest_manhattan_distance = position.manhattan_distance
    end
  end

  for _, position in ipairs(tilebox) do
    local piece = get_piece(position.center, entity.position)

    local remove_scaffold_delay = (largest_manhattan_distance + 4) * FRAMES_BETWEEN_BUILDING

    -- not 100% sure if this is a tick too soon, too late, or just right
    local ttl = 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 18 * TICKS_PER_FRAME

    local top = rendering.draw_animation{
      target = position.center,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-top",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = "higher-object-above",
      visible = false,
    }

    local body = rendering.draw_animation{
      target = position.center,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-body",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = is_back_piece(piece) and "lower-object-above-shadow" or "object",
      visible = false,
    }

    table.insert(entity_being_built.animations, {
      top = top,
      body = body,
      animation_offset_at_tick = {
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  1 * TICKS_PER_FRAME] =  0,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  2 * TICKS_PER_FRAME] =  1,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  3 * TICKS_PER_FRAME] =  2,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  4 * TICKS_PER_FRAME] =  3,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  5 * TICKS_PER_FRAME] =  4,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  6 * TICKS_PER_FRAME] =  5,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  7 * TICKS_PER_FRAME] =  6,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  8 * TICKS_PER_FRAME] =  7,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  9 * TICKS_PER_FRAME] =  8,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 10 * TICKS_PER_FRAME] =  9,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 12 * TICKS_PER_FRAME] = 10,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 13 * TICKS_PER_FRAME] = 11,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 14 * TICKS_PER_FRAME] = 12,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 15 * TICKS_PER_FRAME] = 13,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 16 * TICKS_PER_FRAME] = 14,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 17 * TICKS_PER_FRAME] = 15,

        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  1 * TICKS_PER_FRAME] = 16,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  2 * TICKS_PER_FRAME] = 17,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  3 * TICKS_PER_FRAME] = 18,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  4 * TICKS_PER_FRAME] = 19,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  5 * TICKS_PER_FRAME] = 20,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  6 * TICKS_PER_FRAME] = 21,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  7 * TICKS_PER_FRAME] = 22,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  8 * TICKS_PER_FRAME] = 23,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  9 * TICKS_PER_FRAME] = 24,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 10 * TICKS_PER_FRAME] = 25,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 12 * TICKS_PER_FRAME] = 26,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 13 * TICKS_PER_FRAME] = 27,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 14 * TICKS_PER_FRAME] = 28,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 15 * TICKS_PER_FRAME] = 29,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 16 * TICKS_PER_FRAME] = 30,
        [event.tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 17 * TICKS_PER_FRAME] = 31,
      }
    })
  end

  assert(entity.unit_number)
  storage.entities_being_built[entity.unit_number] = entity_being_built
  -- entity.destroy()
end)

script.on_event(defines.events.on_tick, function(event)
  for _, entity_being_built in pairs(storage.entities_being_built) do
    for _, animation in ipairs(entity_being_built.animations) do
      local animation_offset = animation.animation_offset_at_tick[event.tick]
      if animation_offset ~= nil then
        if animation_offset == 0 then
          animation.top.visible = true
          animation.body.visible = true
        end
        animation.top.animation_offset = animation_offset
        animation.body.animation_offset = animation_offset
      end
    end
  end
end)
