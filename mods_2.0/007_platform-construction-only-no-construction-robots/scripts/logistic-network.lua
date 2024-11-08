local LogisticNetwork = {}

local function remove_all_construction_robot_requests_from_roboport(entity)
  if entity.type ~= "roboport" then return true end -- character toggling editor mode?

  local dirty = false

  local logistic_sections = entity.get_logistic_sections()
  for _, section in ipairs(logistic_sections.sections) do
    for i, filter in ipairs(section.filters) do
      if filter.value.name == "construction-robot" and filter.min > 0 then
        filter.min = 0
        dirty = true
        section.set_slot(i, filter)
      end
    end
  end

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
