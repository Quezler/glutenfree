local flib_bounding_box = require("__flib__.bounding-box")
local blacklisted_names = require("scripts.blacklist")

local UtilityConstants = require("utility-constants")

local print_prefix = '[platform-construction-only-no-construction-robots] '

local Handler = {}

script.on_init(function()
  storage.construction_robots = {}
  storage.lock = {}

  storage.deathrattles = {}

  storage.tasks_at_tick = {}
end)

script.on_configuration_changed(function()
  for unit_number, construction_robot in pairs(storage.construction_robots) do
    if construction_robot.valid == nil then
      construction_robot = construction_robot.entity
    end
  end
end)

local function add_task(tick, task)
  -- assert(tick > game.tick)
  -- assert(task.name)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then
    tasks_at_tick[#tasks_at_tick + 1] = task
  else
    storage.tasks_at_tick[tick] = {task}
  end
end

function Handler.on_tick_robots(event)
  for unit_number, entity in pairs(storage.construction_robots) do
    if entity.valid then
      local robot_order_queue = entity.robot_order_queue
      for _, order in ipairs(robot_order_queue) do
        if order.target then -- target can sometimes be optional
          if order.type == defines.robot_order_type.construct then
            Handler.request_platform_animation_for(order.target)
          end
        end
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

local function get_build_sound_path(selection_box)
  local area = (selection_box.right_bottom.x - selection_box.left_top.x) * (selection_box.right_bottom.y - selection_box.left_top.y)

  if area < UtilityConstants.small_area_size  then return "utility/build_animated_small"  end
  if area < UtilityConstants.medium_area_size then return "utility/build_animated_medium" end
  if area < UtilityConstants.large_area_size  then return "utility/build_animated_large"  end

  return "utility/build_animated_huge"
end

local TICKS_PER_FRAME = 2
local FRAMES_BEFORE_BUILT = 16
local FRAMES_BETWEEN_BUILDING = 8 * 2
local FRAMES_BETWEEN_REMOVING = 4

function Handler.request_platform_animation_for(entity)
  if entity.name ~= "entity-ghost" then return end
  if blacklisted_names[entity.ghost_name] then return end

  -- assert(entity.unit_number)
  if storage.lock[entity.unit_number] then return end

  local tick = game.tick
  local surface = entity.surface

  surface.play_sound{
    path = get_build_sound_path(entity.selection_box),
    position = entity.position,
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

  local remove_scaffold_delay = (largest_manhattan_distance + 4) * FRAMES_BETWEEN_BUILDING
  local all_scaffolding_down_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 16 * TICKS_PER_FRAME

  -- by putting a colliding entity in the center of the building site we'll force the construction robot to wait (between that tick and a second)
  local all_scaffolding_up_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_BUILDING + 15 * TICKS_PER_FRAME
  add_task(all_scaffolding_up_at, {
    name = "destroy",
    entity = surface.create_entity{
      name = "ghost-being-constructed",
      force = "neutral",
      position = entity.position,
      create_build_effect_smoke = false,
      preserve_ghosts_and_corpses = true,
    }
  })

  for _, position in ipairs(tilebox) do
    local piece = get_piece(position.center, entity.position)
    local animations = {} -- local animations = {} -- top & body

    local up_base = tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING
    add_task(up_base + 00 * TICKS_PER_FRAME, {name = "start", animations = animations})
    add_task(up_base + 15 * TICKS_PER_FRAME, {name = "pause", offset = 15, animations = animations})

    local down_base = tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay
    add_task(down_base + 00 * TICKS_PER_FRAME, {name = "unpause", offset = 16, animations = animations})

    local ttl = down_base - tick + 16 * TICKS_PER_FRAME

    animations[1] = rendering.draw_animation{
      target = position.center,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-top",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = entity.ghost_type == "cargo-landing-pad" and "above-inserters" or "higher-object-above",
      visible = false,
    }

    animations[2] = rendering.draw_animation{
      target = position.center,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-body",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = is_back_piece(piece) and "lower-object-above-shadow" or "object",
      visible = false,
    }
  end

  storage.lock[entity.unit_number] = true
  add_task(all_scaffolding_down_at, {name = "unlock", unit_number = entity.unit_number})
end

local function do_tasks_at_tick(tick)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then storage.tasks_at_tick[tick] = nil
    for _, task in ipairs(tasks_at_tick) do
      if task.name == "start" then
        local offset = -(tick * 0.5) % 32
        task.animations[1].visible = true
        task.animations[2].visible = true
        task.animations[1].animation_speed = 1
        task.animations[2].animation_speed = 1
        task.animations[1].animation_offset = offset
        task.animations[2].animation_offset = offset
      elseif task.name == "pause" then
        task.animations[1].animation_speed = 0
        task.animations[2].animation_speed = 0
        task.animations[1].animation_offset = task.offset
        task.animations[2].animation_offset = task.offset
      elseif task.name == "unpause" then
        local offset = -(tick * 0.5) % 32
        task.animations[1].animation_speed = 1
        task.animations[2].animation_speed = 1
        task.animations[1].animation_offset = offset + task.offset
        task.animations[2].animation_offset = offset + task.offset
      elseif task.name == "destroy" then
        task.entity.destroy()
      elseif task.name == "unlock" then
        storage.lock[task.unit_number] = nil
      end
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  Handler.on_tick_robots(event)

  do_tasks_at_tick(event.tick)
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "construction-robot-created" then return end

  local construction_robot = event.target_entity
  assert(construction_robot and construction_robot.name == "construction-robot")

  storage.construction_robots[construction_robot.unit_number] = construction_robot
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.network_id then
      storage.networkdata[deathrattle.network_id] =  nil
    end
  end
end)
