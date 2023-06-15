local storage_chest_names = {
  ["logistic-chest-storage"] = true,
}

local function remove_invalid_entities_from(entities)
  for unit_number, entity in pairs(entities) do
    if not entity.valid then
      entities[unit_number] = nil
    end
  end
end

local Car = require('scripts.car')

--

local Handler = {}

function Handler.on_init()
  -- global.storage_chest_names = {}

  global.surfaces = {}
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
  end

  global.construction_robots = {}
end

-- creation

function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    storage_chests = {}, -- entities keyed by unit number
    car_for = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if storage_chest_names[entity.name] then 
    Handler.tick_storage_chest(entity)
  end
end

-- modification

function Handler.on_gui_closed(event)
  local entity = event.entity
  if entity and storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

function Handler.on_entity_settings_pasted(event)
  local entity = event.destination
  if storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

-- 

function Handler.tick_storage_chest(entity)
  local surfacedata = global.surfaces[entity.surface.index]
  if not (entity.storage_filter and entity.storage_filter.name == "deconstruction-planner") then
    surfacedata.storage_chests[entity.unit_number] = nil
    return
  end

  game.print("recognized")
  surfacedata.storage_chests[entity.unit_number] = entity

  surfacedata.car_for[entity.unit_number] = Car.create_for(entity)

  rendering.draw_animation{
    animation = "logistic-chest-storage",
    surface = entity.surface,
    target = entity,
    render_layer = "higher-object-under",
    animation_speed = 0,
    animation_offset = 7,
  }
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
end

function Handler.on_robot_post_mined(robot)
  local cargo = robot.get_inventory(defines.inventory.robot_cargo)
  if cargo.is_empty() then return end -- somehow picked up nothing

  local surfacedata = global.surfaces[robot.surface.index]
  remove_invalid_entities_from(surfacedata.storage_chests)

  local storage_chest = robot.surface.get_closest(robot.position, surfacedata.storage_chests)
  if storage_chest then
    robot.logistic_network = surfacedata.car_for[storage_chest.unit_number].logistic_network
    -- for _, player in ipairs(robot.force.connected_players) do
    --   player.add_alert(storage_chest, defines.alert_type.no_storage)
    -- end
  end

  game.print(robot.unit_number)
end

--

script.on_init(Handler.on_init)

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
