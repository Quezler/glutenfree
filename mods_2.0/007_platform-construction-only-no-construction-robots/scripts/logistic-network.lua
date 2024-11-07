local LogisticNetwork = {}

local function remove_all_construction_robot_requests_from_roboport(entity)
  assert(entity.type == "roboport")
  local inventory = game.create_inventory(1)
  inventory.insert({name = "blueprint"})
  inventory[1].create_blueprint{
    surface = entity.surface,
    force = entity.force,
    area = entity.bounding_box,
  }

  local blueprint_entities = inventory[1].get_blueprint_entities() or {}
  assert(#blueprint_entities == 1, '#blueprint_entities > 1')
  assert(blueprint_entities[1].name == entity.name, string.format("entity name is %s but expected %s.", blueprint_entities[1].name, entity.name))

  -- error(serpent.block(blueprint_entities[1]))

  local dirty = false

  local request_filters = blueprint_entities[1].request_filters
  if request_filters then

    for _, section in ipairs(request_filters.sections) do
      for _, filter in ipairs(section.filters or {}) do
        if filter.name == "construction-robot" and filter.count > 0 then
          filter.count = 0
          section.name = nil
          dirty = true
        end
      end
    end

    if dirty then
      inventory[1].set_blueprint_entities(blueprint_entities)
      inventory[1].build_blueprint{
        surface = entity.surface,
        force = entity.force,
        position = entity.position,
      }
    end
  end

  inventory.destroy()
  return dirty
end

function LogisticNetwork.remove_all_construction_robot_requests_from_roboports(logistic_network)
  assert(logistic_network)

  local dirty = false

  local cells = logistic_network.cells
  for _, cell in ipairs(cells) do
    if remove_all_construction_robot_requests_from_roboport(cell.owner) then
      dirty = true
    end
  end

  return dirty
end

return LogisticNetwork