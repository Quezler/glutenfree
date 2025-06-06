local Buildings = {}

Buildings.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local playerdata = storage.playerdata[entity.last_user.index]

  if entity.type == "entity-ghost" then
    local tags = entity.tags or {}
    tags[mod_prefix .. "factory-index"] = playerdata.held_factory_index
    entity.tags = tags
    return
  end

  game.print(playerdata.held_factory_index or (event.tags and event.tags[mod_prefix .. "factory-index"]))
end

return Buildings
