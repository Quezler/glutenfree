local Deathrattles = {}

local map = {}

function Deathrattles.add(key, closure)
  assert(map[key] == nil)
end

assert(script.get_event_handler(defines.events.on_object_destroyed) == nil)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    map[deathrattle[1]](deathrattle)
  end
end)

return Deathrattles
