local function logistic_network_is_personal_roboport(logistic_network) -- in a player character
  return #logistic_network.cells == 1 and logistic_network.cells[1].owner.type == "character"
end

--

local Handler = {}

function Handler.on_init()
  global.construction_robots = {}
end

function Handler.on_load()
  if Handler.should_on_tick() then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.should_on_tick()
  return global.construction_robots and #global.construction_robots > 0
end

function Handler.on_tick(event)
  for _, construction_robot in ipairs(global.construction_robots) do
    if construction_robot.valid then
      Handler.after_robot_visited_cargo(construction_robot)
    end
  end

  global.construction_robots = {}
  -- if Handler.should_on_tick() then return end
  script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_robot_pre_mined, function(event)
  if not logistic_network_is_personal_roboport(event.robot.logistic_network) then return end

  table.insert(global.construction_robots, event.robot)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end, {{filter = 'name', name = 'logistic-robot-dropped-cargo'}})

function Handler.after_robot_visited_cargo(robot)
  local cargo = robot.get_inventory(defines.inventory.robot_cargo)
  if cargo.is_empty() then return end -- picked up an empty parcel

  -- what if a player died in the tick a robot picked up dropped cargo? i guess we'll await the reports
  local trash = robot.logistic_network.cells[1].owner.get_inventory(defines.inventory.character_trash)

  -- just teleport the items to the player instantly so we don't have to check each tick if the bot has arrived home yet
  local count = cargo[1].count
  local inserted = trash.insert(cargo[1])

  -- if this crash occurs often we might have to temporarily increase `character_trash_slot_count_bonus` or something
  if count ~= inserted then error('trash slots full?') end

  -- apparently .insert(LuaItemStack) can copy stuff with data like blueprints just fine, so no need to swap stacks.
  cargo[1].clear()
end

--

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)
script.on_configuration_changed(Handler.on_init)
