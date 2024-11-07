local flib_bounding_box = require("__flib__.bounding-box")
local LogisticNetwork = require("scripts.logistic-network")
local blacklisted_names = require("scripts.blacklist")

local print_prefix = '[platform-construction-only-no-construction-robots] '

local Handler = {}

script.on_init(function()
  storage.construction_robots = {}
  storage.lock = {}

  storage.networkdata = {}
  storage.deathrattles = {}

  storage.tasks_at_tick = {}
end)

script.on_configuration_changed(function()
  storage.networkdata = {} -- allowed to reset
end)

local function add_task(tick, task)
  assert(tick > game.tick)
  assert(task.name)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then
    tasks_at_tick[#tasks_at_tick + 1] = task
  else
    storage.tasks_at_tick[tick] = {task}
  end
end

local function get_or_create_networkdata(logistic_network)
  local networkdata = storage.networkdata[logistic_network.network_id]
  if networkdata then
    assert(networkdata.id == logistic_network.network_id)
    return networkdata
  end

  networkdata = {
    id = logistic_network.network_id,
    logistic_network = logistic_network,

    last_roboport_with_space = nil,
    last_roboport_with_space_search_failed_search_at = 0,
  }

  storage.networkdata[logistic_network.network_id] = networkdata
  storage.deathrattles[script.register_on_object_destroyed(logistic_network)] = {network_id = logistic_network.network_id}

  return networkdata
end

local function give_roboport_item(entity, item)
  assert(item.count == 1) -- sanity check

  local inventory = entity.get_inventory(defines.inventory.roboport_robot)
  assert(inventory, entity.name) -- do roboports with no inventory trigger this at all?
  if inventory == nil then return end

  local inserted = inventory.insert(item)
  return inserted == 1
end

local function returned_home_with_milk(construction_robot)
  local logistic_network = construction_robot.logistic_network
  if logistic_network == nil then return end

  local networkdata = get_or_create_networkdata(logistic_network)
  local item = {name = construction_robot.name, count = 1, quality = construction_robot.quality} -- todo: this assumes robot & item share their name

  local last_roboport_with_space = networkdata.last_roboport_with_space
  if last_roboport_with_space and last_roboport_with_space.valid then
    if give_roboport_item(last_roboport_with_space, item) then
      return true
    end
  else
    networkdata.last_roboport_with_space = nil
  end

  -- if we tried looking for a roboport with space in the last 5 seconds and failed, don't search now
  if networkdata.last_roboport_with_space_search_failed_search_at + 300 >= game.tick then return end

  for _, cell in ipairs(logistic_network.cells) do
    if give_roboport_item(cell.owner, item) then
      networkdata.last_roboport_with_space = cell.owner
      return true
    end
  end

  networkdata.last_roboport_with_space_search_failed_search_at = game.tick
end

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
      elseif this_order == nil and entity.logistic_network then
        if event.tick == construction_robot.born_at then
          if LogisticNetwork.remove_all_construction_robot_requests_from_roboports(entity.logistic_network) then
            game.print(string.format(print_prefix .. 'removed construction robot requests in roboports from network #%d on %s.', entity.logistic_network.network_id, entity.surface.name))
          else
            log("thought there were roboports with robot requests, but there were none. (hand deployed a construction robot?)")
          end
        end
        if construction_robot.inventory.is_empty() and returned_home_with_milk(entity) then
          entity.destroy()
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

local TICKS_PER_FRAME = 2
local FRAMES_BEFORE_BUILT = 16
local FRAMES_BETWEEN_BUILDING = 8 * 2
local FRAMES_BETWEEN_REMOVING = 4

function Handler.request_platform_animation_for(entity)
  if entity.name ~= "entity-ghost" then return end
  if blacklisted_names[entity.ghost_name] then return end
  assert(entity.unit_number)
  if storage.lock[entity.unit_number] then return end

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

  -- by putting a colliding entity in the center of the building site we'll force the construction robot to wait (between that tick and a second)
  local scaffolding_up_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_BUILDING + 17 * TICKS_PER_FRAME
  add_task(scaffolding_up_at, {
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

    local animations = {top, body}

    local up_base = tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_BUILDING
    add_task(up_base + 00 * TICKS_PER_FRAME, {name = "unhide", animations = animations})
    add_task(up_base + 01 * TICKS_PER_FRAME, {name = "offset", offset = 01, animations = animations})
    add_task(up_base + 02 * TICKS_PER_FRAME, {name = "offset", offset = 02, animations = animations})
    add_task(up_base + 03 * TICKS_PER_FRAME, {name = "offset", offset = 03, animations = animations})
    add_task(up_base + 04 * TICKS_PER_FRAME, {name = "offset", offset = 04, animations = animations})
    add_task(up_base + 05 * TICKS_PER_FRAME, {name = "offset", offset = 05, animations = animations})
    add_task(up_base + 06 * TICKS_PER_FRAME, {name = "offset", offset = 06, animations = animations})
    add_task(up_base + 07 * TICKS_PER_FRAME, {name = "offset", offset = 07, animations = animations})
    add_task(up_base + 08 * TICKS_PER_FRAME, {name = "offset", offset = 08, animations = animations})
    add_task(up_base + 09 * TICKS_PER_FRAME, {name = "offset", offset = 09, animations = animations})
    add_task(up_base + 10 * TICKS_PER_FRAME, {name = "offset", offset = 10, animations = animations})
    add_task(up_base + 11 * TICKS_PER_FRAME, {name = "offset", offset = 11, animations = animations})
    add_task(up_base + 12 * TICKS_PER_FRAME, {name = "offset", offset = 12, animations = animations})
    add_task(up_base + 13 * TICKS_PER_FRAME, {name = "offset", offset = 13, animations = animations})
    add_task(up_base + 14 * TICKS_PER_FRAME, {name = "offset", offset = 14, animations = animations})
    add_task(up_base + 15 * TICKS_PER_FRAME, {name = "offset", offset = 15, animations = animations})

    local down_base = tick + 1 + position.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay
    add_task(down_base + 00 * TICKS_PER_FRAME, {name = "offset", offset = 16, animations = animations})
    add_task(down_base + 01 * TICKS_PER_FRAME, {name = "offset", offset = 17, animations = animations})
    add_task(down_base + 02 * TICKS_PER_FRAME, {name = "offset", offset = 18, animations = animations})
    add_task(down_base + 03 * TICKS_PER_FRAME, {name = "offset", offset = 19, animations = animations})
    add_task(down_base + 04 * TICKS_PER_FRAME, {name = "offset", offset = 20, animations = animations})
    add_task(down_base + 05 * TICKS_PER_FRAME, {name = "offset", offset = 21, animations = animations})
    add_task(down_base + 06 * TICKS_PER_FRAME, {name = "offset", offset = 22, animations = animations})
    add_task(down_base + 07 * TICKS_PER_FRAME, {name = "offset", offset = 23, animations = animations})
    add_task(down_base + 08 * TICKS_PER_FRAME, {name = "offset", offset = 24, animations = animations})
    add_task(down_base + 09 * TICKS_PER_FRAME, {name = "offset", offset = 25, animations = animations})
    add_task(down_base + 10 * TICKS_PER_FRAME, {name = "offset", offset = 26, animations = animations})
    add_task(down_base + 11 * TICKS_PER_FRAME, {name = "offset", offset = 27, animations = animations})
    add_task(down_base + 12 * TICKS_PER_FRAME, {name = "offset", offset = 28, animations = animations})
    add_task(down_base + 13 * TICKS_PER_FRAME, {name = "offset", offset = 29, animations = animations})
    add_task(down_base + 14 * TICKS_PER_FRAME, {name = "offset", offset = 30, animations = animations})
    add_task(down_base + 15 * TICKS_PER_FRAME, {name = "offset", offset = 31, animations = animations})

    local ttl = down_base - tick + 16 * TICKS_PER_FRAME

    animations[1] = rendering.draw_animation{
      target = position.center,
      surface = surface,
      animation = "platform_entity_build_animations-" .. piece .. "-top",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = "higher-object-above",
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
  add_task(entire_animation_done_at, {name = "unlock", unit_number = entity.unit_number})
end

local function do_tasks_at_tick(tick)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then storage.tasks_at_tick[tick] = nil
    for _, task in ipairs(tasks_at_tick) do
      if task.name == "offset" then
        task.animations[1].animation_offset = task.offset
        task.animations[2].animation_offset = task.offset
      elseif task.name == "unhide" then
        task.animations[1].visible = true
        task.animations[2].visible = true
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
  assert(construction_robot)
  assert(construction_robot.name == "construction-robot")

  storage.construction_robots[construction_robot.unit_number] = {
    entity = construction_robot,
    born_at = event.tick, -- apparently a new robot has no tasks during its first tick, so we won't send them home with milk as a newborn.
    inventory = construction_robot.get_inventory(defines.inventory.robot_cargo),
  }
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.network_id then
      storage.networkdata[deathrattle.network_id] =  nil
    end
  end
end)
