local function logistic_network_is_personal_roboport(logistic_network) -- in a player character
  return #logistic_network.cells == 1 and logistic_network.cells[1].owner.type == "character"
end

script.on_event(defines.events.on_robot_mined_entity, function(event)
  local robot = event.robot

  if logistic_network_is_personal_roboport(robot.logistic_network) then

    -- firsly, try to find a roboport that covers this construction area:
    for _, logistic_network in ipairs(robot.surface.find_logistic_networks_by_construction_area(robot.position, robot.force)) do
      if not logistic_network_is_personal_roboport(logistic_network) then
        robot.logistic_network = logistic_network
        return
      end
    end

    -- otherwise, find the nearest roboport:
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

    error("surface has dropped robot cargo but no roboports at all?")
  end
end, {{filter = 'name', name = 'logistic-robot-dropped-cargo'}})
