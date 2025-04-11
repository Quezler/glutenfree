local function logistic_network_is_personal_roboport(logistic_network) -- in a player character
  return #logistic_network.cells == 1 and logistic_network.cells[1].owner.type == "character"
end

local luasurface = {}
function luasurface.find_closest_logistic_network_by_position(surface, position, force)
  local robot = surface.create_entity{
    name = "construction-robot",
    force = force,
    position = position,
  }

  local logistic_network = robot.logistic_network
  robot.destroy()

  return logistic_network
end

--

local Handler = {}

function Handler.on_init()
  storage.construction_robots = {}
end

function Handler.on_load()
  if Handler.should_on_tick() then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.should_on_tick()
  return storage.construction_robots and #storage.construction_robots > 0
end

function Handler.on_tick(event)
  for _, construction_robot in ipairs(storage.construction_robots) do
    if construction_robot.valid then
      Handler.after_robot_visited_cargo(construction_robot)
    end
  end

  storage.construction_robots = {}
  -- if Handler.should_on_tick() then return end
  script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_robot_pre_mined, function(event)
  if not logistic_network_is_personal_roboport(event.robot.logistic_network) then return end

  table.insert(storage.construction_robots, event.robot)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end, {{filter = "name", name = "logistic-robot-dropped-cargo"}})

function Handler.after_robot_visited_cargo(robot)
  local cargo = robot.get_inventory(defines.inventory.robot_cargo)
  if cargo.is_empty() then return end -- picked up an empty parcel

  -- what if a player died in the tick a robot picked up dropped cargo? i guess we"ll await the reports
  local trash = robot.logistic_network.cells[1].owner.get_inventory(defines.inventory.character_trash)

  -- just teleport the items to the player instantly so we don't have to check each tick if the bot has arrived home yet.
  local count = cargo[1].count
  local inserted = trash.insert(cargo[1])
  cargo[1].count = cargo[1].count - inserted

  if count == inserted then return end -- all good

  local logistic_network = luasurface.find_closest_logistic_network_by_position(robot.surface, robot.position, robot.force)
  if logistic_network then
    robot.logistic_network = logistic_network
    return
  end

  -- apparently .insert(LuaItemStack) can copy stuff with data like blueprints just fine, so no need to swap stacks.
  cargo[1].clear()
  error("achievement get! how did we get here?")
end

--

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)
script.on_configuration_changed(Handler.on_init)
