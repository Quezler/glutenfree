local construction_robot = {}

function construction_robot.deliver(entity, modules)
  return entity.surface.create_entity{name = "item-request-proxy", target = entity, modules = modules, position = entity.position, force = entity.force}
end

function construction_robot.pending_delivery(entity)
  return entity.surface.find_entity("item-request-proxy", {entity.position.x, entity.position.y}) ~= nil
end

return construction_robot
