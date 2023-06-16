local function remove_invalid_entities_from(entities)
  for unit_number, entity in pairs(entities) do
    if not entity.valid then
      entities[unit_number] = nil
    end
  end
end

local util = require("__core__.lualib.util")

local Car = require('scripts.car')

--

local Handler = {}

function Handler.on_init()
  global.surfaces = {}
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
  end

  global.construction_robots = {}
  global.robots_to_check_at_tick = {}

  Handler.on_configuration_changed()
end

function Handler.on_configuration_changed()
  global.storage_chest_names = {}
  global.aimation_offset_for = {}

  -- {"", {"logistic-chest-storage", "7"}} -- vanilla
  -- {"", {"logistic-chest-storage", "8"}, {"aai-strongbox-storage", "8"}, {"aai-storehouse-storage", "8"}, {"aai-warehouse-storage", "8"}} -- aai containers
  for _, pair in pairs(game.equipment_grid_prototypes["logistic-chest-deconstruction-equipment-grid"].localised_description) do
    if type(pair) == "table" then
      global.storage_chest_names[pair[1]] = pair[1]
      global.aimation_offset_for[pair[1]] = tonumber(pair[2])
    end
  end

  global.robot_prototype_for = {}
  for _, robot in pairs(game.get_filtered_entity_prototypes{{filter="type", type = "construction-robot"}}) do
    global.robot_prototype_for[robot.name] = {
      max_speed = robot.max_speed,
      speed = robot.speed,
      speed_multiplier_when_out_of_energy = robot.speed_multiplier_when_out_of_energy,
    }
  end
end

-- creation

function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    storage_chests = {}, -- entities keyed by unit number
    car_for = {},
    sunroof_for = {},
    storage_chest_for = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if global.storage_chest_names[entity.name] then 
    Handler.tick_storage_chest(entity)
  end
end

-- modification

function Handler.on_gui_closed(event)
  local entity = event.entity
  if entity and global.storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

function Handler.on_entity_settings_pasted(event)
  local entity = event.destination
  if global.storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

-- 

function Handler.tick_storage_chest(entity)
  local surfacedata = global.surfaces[entity.surface.index]
  if not (entity.storage_filter and entity.storage_filter.name == "deconstruction-planner") then
    surfacedata.storage_chests[entity.unit_number] = nil
    
    local sunroof_id = surfacedata.sunroof_for[entity.unit_number]
    if sunroof_id then surfacedata.sunroof_for[entity.unit_number] = nil
      rendering.destroy(sunroof_id)
    end

    return
  end

  game.print("recognized")
  surfacedata.storage_chests[entity.unit_number] = entity

  local car = Car.create_for(entity)
  surfacedata.car_for[entity.unit_number] = car
  surfacedata.storage_chest_for[car.unit_number] = entity

  local sunroof_id = rendering.draw_animation{
    animation = entity.name,
    surface = entity.surface,
    target = entity,
    render_layer = "130", -- 1 above "object"
    animation_speed = 0,
    animation_offset = global.aimation_offset_for[entity.name] - 1, -- offset ontop of 1
  }

  surfacedata.sunroof_for[entity.unit_number] = sunroof_id
end

--

script.on_event(defines.events.on_robot_pre_mined, function(event)
  table.insert(global.construction_robots, event.robot)
end)

function Handler.on_tick(event)
  for _, construction_robot in ipairs(global.construction_robots) do
    Handler.on_robot_post_mined(construction_robot)
  end

  global.construction_robots = {}

  -- global.travelers = {} -- construction bots far away from their storage chest
  -- global.overheads = {} -- construction bots very close to their storage chest

  -- under normal circumstances bots should only be in here once
  -- if a bot runs out of power (which they likely will) they'll be added back but based on their out of energy move speed
  -- todo: likewise if there's no storage space to drop off
  local robots_to_check = global.robots_to_check_at_tick[event.tick]
  if robots_to_check then global.robots_to_check_at_tick[event.tick] = nil
    for _, robot_task in ipairs(robots_to_check) do
      if robot_task.robot.valid then
        -- game.print('checking robot ' .. robot_task.robot.unit_number)
        Handler.tick_construction_robot(robot_task)
      end
    end
  end

end

function Handler.check_robot_at_tick(robot_task, tick)
  if not global.robots_to_check_at_tick[tick] then global.robots_to_check_at_tick[tick] = {} end
  global.robots_to_check_at_tick[tick][#global.robots_to_check_at_tick[tick] + 1] = robot_task
end

function Handler.on_robot_post_mined(robot)
  local cargo = robot.get_inventory(defines.inventory.robot_cargo)
  if cargo.is_empty() then return end -- somehow picked up nothing

  local surfacedata = global.surfaces[robot.surface.index]
  remove_invalid_entities_from(surfacedata.storage_chests)

  local storage_chest = robot.surface.get_closest(robot.position, surfacedata.storage_chests)
  if storage_chest then
    robot.logistic_network = surfacedata.car_for[storage_chest.unit_number].logistic_network
    Handler.tick_construction_robot({
      robot = robot,
      attempts = 0,
    })
  end
end

function Handler.tick_construction_robot(robot_task)
  assert(type(robot_task.attempts) == "number", "robot_task.attempts isn't a number.")
  robot_task.attempts = robot_task.attempts + 1 -- ideally 3: initial travel estimate, final tile & dropoff
  -- game.print('robot attempt #' .. robot_task.attempts)

  local robot = robot_task.robot

  -- local storage_chest = robot.logistic_cell.owner
  assert(#robot.logistic_network.cells == 1, "construction robot escaped into another network.")
  local car = robot.logistic_network.cells[1].owner
  local distance = util.distance(robot.position, car.position)

  game.print(string.format("bot %d's distance is %f", robot.unit_number, distance))

  if distance > 0.1 then
    -- shoutout to calciumwizard for pointing out it was off
    local prototype = global.robot_prototype_for[robot.name]
    local speed = math.min(prototype.max_speed, prototype.speed * (1 + robot.force.worker_robots_speed_modifier))
    speed = math.min(prototype.max_speed, (robot.energy == 0 and prototype.speed_multiplier_when_out_of_energy or 1) * speed)

    local ticks = math.ceil(distance / speed) -- ticks till overhead
    local at_tick = game.tick + ticks
    assert(ticks > 0, "cannot schedule for the current tick")

    game.print(string.format("at speed %f i'll travel %f tiles in %d ticks", speed, distance, ticks))

    Handler.check_robot_at_tick(robot_task, at_tick)
  else
    local surfacedata = global.surfaces[robot.surface_index]
    local storage_chest = surfacedata.storage_chest_for[car.unit_number]

    local inventory = storage_chest.get_inventory(defines.inventory.chest)
    local cargo_stack = robot.get_inventory(defines.inventory.robot_cargo)[1]

    local inserted = inventory.insert(cargo_stack)
    cargo_stack.count = cargo_stack.count - inserted

    if cargo_stack.count == 0 then
      robot.logistic_network = storage_chest.logistic_network -- todo: will crash in case of roboport coverage loss (power/removal)
    else
      for _, player in ipairs(robot.force.connected_players) do
        player.add_alert(storage_chest, defines.alert_type.no_storage)
      end

      local at_tick = game.tick + 60
      Handler.check_robot_at_tick(robot_task, at_tick)
    end
  end
end

--

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

script.on_event(defines.events.on_gui_closed, Handler.on_gui_closed)
script.on_event(defines.events.on_entity_settings_pasted, Handler.on_entity_settings_pasted)

local events = {
  [defines.events.on_surface_created] = Handler.on_surface_created,
  [defines.events.on_surface_deleted] = Handler.on_surface_deleted,

  [defines.events.on_built_entity]       = Handler.on_created_entity,
  [defines.events.on_robot_built_entity] = Handler.on_created_entity,
  [defines.events.script_raised_built]   = Handler.on_created_entity,
  [defines.events.script_raised_revive]  = Handler.on_created_entity,
  [defines.events.on_entity_cloned]      = Handler.on_created_entity,

  [defines.events.on_tick] = Handler.on_tick,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
