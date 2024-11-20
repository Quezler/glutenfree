local logistic_mode_can_request = {
  requester = true,
  buffer = true,
}

local requester_chest_names = {}
local prototypes = prototypes.get_entity_filtered{{filter = "type", type = "logistic-container"}}
for _, prototype in pairs(prototypes) do
  if logistic_mode_can_request[prototype.logistic_mode] then
    requester_chest_names[prototype.name] = true
  end
end

local function compatible(event)
  return event.source.type == 'assembling-machine' and requester_chest_names[event.destination.name]
end

local function serialize_requests(requester_chest)
  local manual_filters = {}
  -- local manual_sections = 0

  for _, section in ipairs(requester_chest.get_logistic_sections().sections) do
    if section.type == defines.logistic_section_type.manual then
      -- manual_sections = manual_sections + 1
      for _, filter in ipairs(section.filters) do
        if filter.value then
          filter.section_multiplier = section.multiplier -- sneaking it in here
          table.insert(manual_filters, filter)
        end
      end
    end
  end

  -- return manual_filters, manual_sections
  return manual_filters
end

-- only exists within a tick
local _global = {}

script.on_event(defines.events.on_pre_entity_settings_pasted, function(event)
  if not compatible(event) then return end
  local requester_chest = event.destination

  _global[requester_chest.unit_number] = serialize_requests(requester_chest)
end)

local function requests_match(old_requests, new_requests)
  if table_size(old_requests) ~= table_size(new_requests) then
    return false
  end

  for i = 1, table_size(new_requests) do
    if old_requests[i].value.name ~= new_requests[i].value.name then return false end
    if old_requests[i].value.quality ~= new_requests[i].value.quality then return false end
    if old_requests[i].min ~= new_requests[i].min then return false end
  end

  return true
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if not compatible(event) then return end
  local requester_chest = event.destination

  local old_requests = _global[requester_chest.unit_number] -- this might contain gaps
  local new_requests = serialize_requests(requester_chest) -- this never contains gaps

  _global[requester_chest.unit_number] = nil
  local set_multiplier = 1

  local matches = requests_match(old_requests, new_requests)
  if matches and table_size(new_requests) > 0 then
    -- game.print(serpent.block(old_requests))
    -- game.print(serpent.block(new_requests))
    for _, section in ipairs(requester_chest.get_logistic_sections().sections) do
      if section.type == defines.logistic_section_type.manual then
        section.multiplier = old_requests[1].section_multiplier + 1
        set_multiplier = section.multiplier
        break
      end
    end
  end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.create_local_flying_text{
    text = 'x' .. set_multiplier,
    create_at_cursor = true,
  }
end)
