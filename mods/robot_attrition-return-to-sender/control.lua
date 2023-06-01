local function logistic_network_is_personal_roboport(logistic_network) -- in a player character
  return #logistic_network.cells == 1 and logistic_network.cells[1].owner.type == "character"
end

--

local Handler = {}

function Handler.on_init()
  global.construction_robots = {}
end

function Handler.on_load()
  if global.construction_robots and #global.construction_robots > 0 then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.on_tick(event)
  for _, construction_robot in ipairs(global.construction_robots) do
    if construction_robot.valid then
      Handler.fitting_name(construction_robot)
    end
  end

  global.construction_robots = {}
  script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_robot_pre_mined, function(event)
  table.insert(global.construction_robots, event.robot)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end, {{filter = 'name', name = 'logistic-robot-dropped-cargo'}})

function Handler.fitting_name(robot)
  local cargo = robot.get_inventory(defines.inventory.robot_cargo)
  if cargo.is_empty() then return end -- picked up an empty parcel

  if not logistic_network_is_personal_roboport(robot.logistic_network) then return end

  -- by construction area
  for _, logistic_network in ipairs(robot.surface.find_logistic_networks_by_construction_area(robot.position, robot.force)) do
    if not logistic_network_is_personal_roboport(logistic_network) then
      robot.logistic_network = logistic_network
      return
    end
  end

  -- by surface
  local bot = robot.surface.create_entity{
    name = robot.name,
    force = robot.force,
    position = robot.position,
  }

  local logistic_network = bot.logistic_network
  bot.destroy()

  if logistic_network then
    robot.logistic_network = logistic_network
    return
  end

  -- will i ever forgive myself for allowing several dropped cargo's to stack for this edge case?
  local drop = robot.surface.create_entity{
    name = "logistic-robot-dropped-cargo",
    position = robot.position,
    force = robot.force
  }
  local item_stack = cargo[1]
  drop.get_inventory(defines.inventory.chest)[1].transfer_stack(item_stack)
end

--

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)
script.on_configuration_changed(Handler.on_init)
