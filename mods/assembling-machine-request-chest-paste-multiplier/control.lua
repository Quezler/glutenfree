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

local function incompatible(event)
  return (event.source.type == 'assembling-machine' and global.requester_chest_names[event.destination.name]) == false
end

local function serialize_requests(requester_chest)
  local requests = {}

  for i = 1, requester_chest.request_slot_count do
    requests[i] = requester_chest.get_request_slot(i)
  end

  return requests
end

-- only exists within a tick, should not cause any desyncs right?
local _global = {}

script.on_event(defines.events.on_pre_entity_settings_pasted, function(event)
  if incompatible(event) then return end
  -- game.print(event.source.name)
  -- game.print(event.destination.name)

  local requester_chest = event.destination
  _global[requester_chest.unit_number] = serialize_requests(requester_chest)
end)

local function requests_match(old_requests, new_requests)
  if table_size(old_requests) ~= table_size(new_requests) then
    return false,  "size mismatch"
  end

  for i = 1, table_size(new_requests) do
    if old_requests[i].name ~= new_requests[i].name then return false, "name mismatch at #" .. i end
    if old_requests[i].count ~= new_requests[i].count then return false, "count mismatch at #" .. i end
  end

  return true
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if incompatible(event) then return end
  -- game.print(event.source.name)
  -- game.print(event.destination.name)

  local requester_chest = event.destination

  local old_requests = _global[requester_chest.unit_number] -- this might contain gaps
  local new_requests = serialize_requests(requester_chest) -- this never contains gaps

  _global[requester_chest.unit_number] = nil

  -- log(serpent.block(old_requests))
  -- log(serpent.block(new_requests))

  local matches, reason = requests_match(old_requests, new_requests)
  -- game.print(reason)

  if matches then
    for i = 1, table_size(new_requests) do
      requester_chest.set_request_slot({
        name = new_requests[i].name,
        count = new_requests[i].count * 2,
      }, i)
    end

    local player = assert(game.get_player(event.player_index))
    player.create_local_flying_text{
      text = 'x2',
      create_at_cursor = true,
    }
  end
end)
