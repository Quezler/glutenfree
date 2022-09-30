local laptop = {}

function laptop.init()
  global.deathrattles = global.deathrattles or {}
end

function laptop.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name == 'aai-signal-receiver' then laptop.register_receiver(entity) end
  if entity.name == 'aai-signal-sender' then laptop.register_sender(entity) end
end

function laptop.register_receiver(entity)
  local position = entity.position

  position.x = position.x + 3.19921875
  position.y = position.y + 3.17187500

  local computer = laptop.create_laptop_on_at(entity, position)
end

function laptop.register_sender(entity)
  local position = entity.position

  position.x = position.x + 1.83984375
  position.y = position.y + 1.12890625

  local computer = laptop.create_laptop_on_at(entity, position)
end

function laptop.create_laptop_on_at(entity, position)
  local computer = entity.surface.create_entity({
    name = 'glutenfree-aai-signal-transmission-preview-laptop',
    force = entity.force,
    position = position,
  })

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {computer}

  computer.operable = false
  computer.destructible = false

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
