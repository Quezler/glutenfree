local laptop = {}

local desks = {}
desks['aai-signal-receiver'] = {x = 3.19921875, y = 3.17187500}
desks['aai-signal-sender'  ] = {x = 1.83984375, y = 1.12890625}

local surface_name = 'glutenfree-aai-signal-transmission-preview-deepweb'

function laptop.init()
  -- print('init')
  global.deathrattles = global.deathrattles or {}

  for registration_number, entities in pairs(global.deathrattles) do
    for _, entity in pairs(entities) do
      entity.destroy()
    end
  end

  global.deathrattles = {}
  -- if game.surfaces[surface_name] then game.delete_surface(surface_name) end
  -- print('surface deleted')

  --

  for _, surface in pairs(game.surfaces) do
    for name, offset in pairs(desks) do
      for _, entity in pairs(surface.find_entities_filtered{name = name}) do
        laptop.register_desk(entity)
      end
    end
  end
end

function laptop.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if desks[entity.name] then laptop.register_desk(entity) end
end

function laptop.register_desk(entity)
  local computer = laptop.create_laptop_on(entity, desks[entity.name])
end

function laptop.create_laptop_on(entity, offset)
  local computer = entity.surface.create_entity({
    name = 'glutenfree-aai-signal-transmission-preview-laptop',
    force = entity.force,
    position = {entity.position.x + offset.x, entity.position.y + offset.y},
  })

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {computer}

  computer.operable = false
  computer.destructible = false

  -- connect red wire
  computer.connect_neighbour({
    target_entity = entity,
    wire = defines.wire_type.red,
  })

  -- connect green wire
  computer.connect_neighbour({
    target_entity = entity,
    wire = defines.wire_type.green,
  })

  local anchors = {}
  local surface = laptop.deepweb()

  -- surface.request_to_generate_chunks(computer.position, 1)
  -- surface.generate_with_lab_tiles = true
  -- surface.force_generate_chunk_requests()

  for i = 1, 5 do
    anchors[i] = surface.create_entity({
      name = 'glutenfree-aai-signal-transmission-preview-laptop-anchor-' .. i,
      force = entity.force,
      position = computer.position,
    })
    -- print(i .. serpent.block(anchors[i]) .. serpent.line(anchors[i].position) .. serpent.line( anchors[i].valid ))
  end

  -- ensure all of the 5 copper connections are empty
  computer.disconnect_neighbour()

  -- disconnect the 5 anchors from eachother
  for _, anchor in ipairs(anchors) do
    anchor.disconnect_neighbour()
  end

  -- connect each of the 5 anchors to the computer
  for _, anchor in ipairs(anchors) do
    computer.connect_neighbour(anchor)
  end

  -- cascade anchor deletion if the laptop gets destroyed
  global.deathrattles[script.register_on_entity_destroyed(computer)] = anchors

  -- game.print(surface.index)
  -- game.print(surface.name)

  return computer
end

function laptop.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

function laptop.deepweb()
  if game.surfaces[surface_name] then
    -- print("returned surface")
    return game.surfaces[surface_name]
  end

  local surface = game.create_surface(surface_name)
  surface.generate_with_lab_tiles = true

  -- surface.request_to_generate_chunks({0,0}, 1)
  -- surface.force_generate_chunk_requests()
  -- surface.clear() -- so the intial chunk is just lab tiles as well
  -- surface.request_to_generate_chunks({0,0}, 1)
  -- surface.force_generate_chunk_requests()
  -- print("made surface")

  return surface
end

return laptop
