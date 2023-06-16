function Handler.on_gui_closed(event)
  local entity = event.entity
  if entity and global.storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

function Handler.on_entity_settings_pasted(event)
  local entity = event.destination
  if global.storage_chest_names[entity.name] then
    Handler.tick_storage_chest(entity)
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if global.storage_chest_names[entity.name] then 
    Handler.tick_storage_chest(entity)
  end
end
