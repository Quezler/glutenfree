local logistic_mode_can_request = {
  requester = true,
  buffer = true,
}

local function on_configuration_changed()
  global.requester_chest_names = {}

  local prototypes = game.get_filtered_entity_prototypes{{filter = "type", type = "logistic-container"}}
  for _, prototype in pairs(prototypes) do
    if logistic_mode_can_request[prototype.logistic_mode] then
      global.requester_chest_names[prototype.name] = true
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function compatible(event)
  return event.source.type == 'assembling-machine' and global.requester_chest_names[event.destination.name]
end

local function serialize_requests(requester_chest)
  local requests = {}

  for i = 1, requester_chest.request_slot_count do
    requests[i] = requester_chest.get_request_slot(i)
  end

  return requests
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

  local multiplier = nil

  for i = 1, table_size(new_requests) do
    if old_requests[i].name ~= new_requests[i].name then return false end

    if multiplier == nil then -- effectifely `i == 1`
      multiplier = old_requests[i].count / new_requests[i].count -- 20 / 10 = 2

      -- if multiplier is a decimal it cannot possibly be from multiplication 
      if math.floor(multiplier) ~= multiplier then return false end
    end

    -- check if the old requests all match using the current multiplication level
    if old_requests[i].count ~= new_requests[i].count * multiplier then return false end
  end

  -- all the multiplications match, increment the total amount
  return true, multiplier + 1
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if not compatible(event) then return end
  local requester_chest = event.destination

  local old_requests = _global[requester_chest.unit_number] -- this might contain gaps
  local new_requests = serialize_requests(requester_chest) -- this never contains gaps

  _global[requester_chest.unit_number] = nil

  local matches, multiplier = requests_match(old_requests, new_requests)
  if matches then
    for i = 1, table_size(new_requests) do
      requester_chest.set_request_slot({
        name = new_requests[i].name,
        count = new_requests[i].count * multiplier,
      }, i)
    end
  end

  local player = assert(game.get_player(event.player_index))
  player.create_local_flying_text{
    text = 'x' .. (multiplier or 1),
    create_at_cursor = true,
  }
end)
