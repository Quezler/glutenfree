local flib_bounding_box = require("__flib__.bounding-box")

local Handler = {}

script.on_init(function()
  storage.construction_robots = {}
  storage.entities_being_built = {}
end)

script.on_configuration_changed(function()

end)

function Handler.on_tick_robots(event)
  for unit_number, construction_robot in pairs(storage.construction_robots) do
    local entity = construction_robot.entity
    if entity.valid then
      local robot_order_queue = entity.robot_order_queue
      local this_order = robot_order_queue[1]

      if this_order and this_order.target then -- target can sometimes be optional
        -- todo: construction robots sleep when there is no enemy around, pr or spawn invisible biters?
        -- looks like ->activeNeighbourForcesSet/show-active-forces-around debug is rather generous btw
        assert(entity.teleport(this_order.target.position))
        if this_order.type == defines.robot_order_type.construct then
          Handler.request_platform_animation_for(this_order.target)
        end
      elseif construction_robot.teleported_to_starting_position == false then
        construction_robot.teleported_to_starting_position = true
        entity.teleport(construction_robot.starting_position)
      end
    else
      storage.construction_robots[unit_number] = nil
    end
  end
end

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
local FRAMES_BETWEEN_BUILDING = 8 * 2
local FRAMES_BETWEEN_REMOVING = 4

function Handler.request_platform_animation_for(entity)
  if entity.name ~= "entity-ghost" then return end
  assert(entity.unit_number)
  if storage.entities_being_built[entity.unit_number] then return end

  local tick = game.tick
  local surface = entity.surface

  local tilebox = get_tilebox(entity.bounding_box)
  local largest_manhattan_distance = 0
  for _, position in ipairs(tilebox) do
    position.center = {x = position.x + 0.5, y = position.y + 0.5}
    position.manhattan_distance = get_manhattan_distance(position.center, entity.position)

    if position.manhattan_distance > largest_manhattan_distance then
      largest_manhattan_distance = position.manhattan_distance
    end
  end

  local remove_scaffold_delay = (largest_manhattan_distance + 4) * FRAMES_BETWEEN_BUILDING
  local entire_animation_done_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 18 * TICKS_PER_FRAME

  local entity_being_built = {
    entity = entity,
    entire_animation_done_at = entire_animation_done_at,

    -- by putting a colliding entity in the center of the building site we'll force the construction robot to wait (between that tick and a second)
    scaffolding_up_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_BUILDING + 17 * TICKS_PER_FRAME,
    elevator_music = nil,

    animations = {},
  }

  entity_being_built.elevator_music = surface.create_entity{
    name = "ghost-being-constructed",
    force = "neutral",
    position = entity.position,
    create_build_effect_smoke = false,
    preserve_ghosts_and_corpses = true,
  }

  for _, position in ipairs(tilebox) do
    local piece = get_piece(position.center, entity.position)

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
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  1 * TICKS_PER_FRAME] =  0,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  2 * TICKS_PER_FRAME] =  1,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  3 * TICKS_PER_FRAME] =  2,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  4 * TICKS_PER_FRAME] =  3,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  5 * TICKS_PER_FRAME] =  4,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  6 * TICKS_PER_FRAME] =  5,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  7 * TICKS_PER_FRAME] =  6,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  8 * TICKS_PER_FRAME] =  7,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING +  9 * TICKS_PER_FRAME] =  8,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 10 * TICKS_PER_FRAME] =  9,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 12 * TICKS_PER_FRAME] = 10,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 13 * TICKS_PER_FRAME] = 11,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 14 * TICKS_PER_FRAME] = 12,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 15 * TICKS_PER_FRAME] = 13,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 16 * TICKS_PER_FRAME] = 14,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING + 17 * TICKS_PER_FRAME] = 15,

        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  1 * TICKS_PER_FRAME] = 16,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  2 * TICKS_PER_FRAME] = 17,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  3 * TICKS_PER_FRAME] = 18,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  4 * TICKS_PER_FRAME] = 19,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  5 * TICKS_PER_FRAME] = 20,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  6 * TICKS_PER_FRAME] = 21,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  7 * TICKS_PER_FRAME] = 22,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  8 * TICKS_PER_FRAME] = 23,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay +  9 * TICKS_PER_FRAME] = 24,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 10 * TICKS_PER_FRAME] = 25,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 12 * TICKS_PER_FRAME] = 26,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 13 * TICKS_PER_FRAME] = 27,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 14 * TICKS_PER_FRAME] = 28,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 15 * TICKS_PER_FRAME] = 29,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 16 * TICKS_PER_FRAME] = 30,
        [tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 17 * TICKS_PER_FRAME] = 31,
      }
    })
  end

  storage.entities_being_built[entity.unit_number] = entity_being_built
end

function Handler.on_tick_entities_being_built(event)
  for _, entity_being_built in pairs(storage.entities_being_built) do
    if entity_being_built.entire_animation_done_at == event.tick then -- seems to be timed perfectly, well done quez! - quez
      storage.entities_being_built[_] = nil
      -- game.print("done")
    else
      if entity_being_built.scaffolding_up_at == event.tick then
        entity_being_built.elevator_music.destroy()
      end

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
  end
end

script.on_event(defines.events.on_tick, function(event)
  Handler.on_tick_robots(event)
  Handler.on_tick_entities_being_built(event)
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "construction-robot-created" then return end

  local construction_robot = event.target_entity
  assert(construction_robot)
  assert(construction_robot.name == "construction-robot")

  storage.construction_robots[construction_robot.unit_number] = {
    entity = construction_robot,
    starting_position = construction_robot.position,
    teleported_to_starting_position = false,
  }
end)

