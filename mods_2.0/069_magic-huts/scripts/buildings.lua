local Buildings = {}

local function get_factory_index(event)
  local entity = event.entity or event.destination

  if event.player_index and storage.playerdata[event.player_index] then
    local held_factory_index = storage.playerdata[event.player_index].held_factory_index
    if held_factory_index then -- if nil, go for checking the ghost tags
      return held_factory_index
    end
  end

  if event.tags and event.tags[mod_prefix .. "factory-index"] then
    return event.tags[mod_prefix .. "factory-index"]
  end

  if entity.last_user and storage.playerdata[entity.last_user.index] then
    return storage.playerdata[entity.last_user.index].held_factory_index
  end

  return nil
end

Buildings.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local factory_index = get_factory_index(event)

  if entity.type == "entity-ghost" then
    if factory_index then
      local tags = entity.tags or {}
      tags[mod_prefix .. "factory-index"] = factory_index
      entity.tags = tags
    end
    return
  end

  game.print(factory_index)
end

return Buildings
