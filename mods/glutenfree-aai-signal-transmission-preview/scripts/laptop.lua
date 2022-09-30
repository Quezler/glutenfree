local laptop = {}

local desks = {}
desks['aai-signal-receiver'] = {x = 3.19921875, y = 3.17187500}
desks['aai-signal-sender'  ] = {x = 1.83984375, y = 1.12890625}

function laptop.init()
  global.deathrattles = global.deathrattles or {}
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

  return computer
end

function laptop.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

return laptop
