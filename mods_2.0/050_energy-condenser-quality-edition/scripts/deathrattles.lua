assert(Deathrattles == nil)
Deathrattles = {}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    Deathrattles[deathrattle[1]](deathrattle)
  end
end)
