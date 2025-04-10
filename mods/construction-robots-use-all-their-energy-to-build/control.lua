local function logistic_network_is_personal(logistic_network)
  local cells = logistic_network.cells
  return #cells == 1 and cells[1].owner.type == "character"
end

local function drain_battery(event)
  local robot = event.robot

  if logistic_network_is_personal(robot.logistic_network) then return end

  robot.energy = 0
end

script.on_event(defines.events.on_robot_built_entity, drain_battery)
script.on_event(defines.events.on_robot_built_tile, drain_battery)

-- script.on_event(defines.events.on_robot_mined, drain_battery) -- this happens for every bot that tries to help mine a thing
script.on_event(defines.events.on_robot_mined_entity, drain_battery) -- this is only for the bot that does the final pickup

-- note how there is no event for proxy delivery
script.on_event(defines.events.on_robot_mined_tile, drain_battery)
-- script.on_event(defines.events.on_robot_exploded_cliff, drain_battery) -- does not look good
