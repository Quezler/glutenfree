local laptop = {}

local desks = {}
desks['aai-signal-receiver'] = {x = 3.19921875, y = 3.17187500}
desks['aai-signal-sender'  ] = {x = 1.83984375, y = 1.12890625}

local surface_name = 'glutenfree-aai-signal-transmission-preview-deepweb'

function laptop.init()
  global.deathrattles = global.deathrattles or {}

  for registration_number, entities in pairs(global.deathrattles) do
    for _, entity in pairs(entities) do
      entity.destroy()
    end
  end

  global.deathrattles = {} -- effectively the same as setting each registration_number to nil, but this is just one call.

  -- if game.surfaces[surface_name] then
  --   for _, entity in ipairs(game.get_surface(surface_name).find_entities()) do
  --     entity.destroy()
  --   end
  -- end

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

  for i = 1, 5 do
    anchors[i] = surface.create_entity({
      name = 'glutenfree-aai-signal-transmission-preview-laptop-anchor-' .. i,
      force = entity.force,
      position = computer.position,
    })
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
    return game.surfaces[surface_name]
  end

  local surface = game.create_surface(surface_name)
  surface.generate_with_lab_tiles = true

  return surface
end

return laptop
