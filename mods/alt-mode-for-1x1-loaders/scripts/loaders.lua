local loaders = {}

function loaders.init()
  global.container_for_loader = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = "alt-mode-indicator-for-1x1-loaders"})) do
      entity.destroy()
    end

    for _, entity in pairs(surface.find_entities_filtered({type = "loader-1x1"})) do
      loaders.sync_loader(entity)
    end
  end
end

function loaders.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  if not (entity.type == "loader-1x1") then return end

  -- game.print(entity.name)
  -- game.print(entity.unit_number)

  loaders.sync_loader(entity)
end

function loaders.get_or_create_container(entity)
  local container = global.container_for_loader[entity.unit_number]

  if not container or not container.valid then
    print("creating container for loader [".. entity.unit_number .."].")
    container = entity.surface.create_entity({
      name = 'alt-mode-indicator-for-1x1-loaders',
      position = entity.position,
      force = 'neutral',
    })

    container.destructible = false

    global.container_for_loader[entity.unit_number] = container
  end

  return container
end

function loaders.on_gui_closed(event)
  if (event.gui_type ~= defines.gui_type.entity) then return end
  if (event.entity.type ~= "loader-1x1") then return end

  -- game.print("loader gui closed")
  loaders.sync_loader(event.entity)
end

function loaders.on_entity_settings_pasted(event)
  if (event.destination.type ~= "loader-1x1") then return end

  -- game.print("loader gui pasted")
  loaders.sync_loader(event.destination)
end

function loaders.sync_loader(entity)
  local container = loaders.get_or_create_container(entity)
  local inventory = container.get_inventory(defines.inventory.chest)
  inventory.clear()

  if (entity.loader_type == "output") then

    for i = 1, entity.filter_slot_count do
      if entity.get_filter(i) then
        inventory.insert({ name = entity.get_filter(i) })
      end
    end
  end
end

function loaders.on_entity_removed(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if (event.entity.type ~= "loader-1x1") then return end

  global.container_for_loader[entity.unit_number].destroy()
  global.container_for_loader[entity.unit_number] = nil
end

function loaders.on_player_rotated_entity(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if (event.entity.type ~= "loader-1x1") then return end

  -- game.print("loader rotated")
  loaders.sync_loader(entity)
end

return loaders
