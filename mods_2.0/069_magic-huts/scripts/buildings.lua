local Buildings = {}

Buildings.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local playerdata = storage.playerdata[entity.last_user.index]

  game.print(playerdata.held_factory_index)
end

return Buildings
