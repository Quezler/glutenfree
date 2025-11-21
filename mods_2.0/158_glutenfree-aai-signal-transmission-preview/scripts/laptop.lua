local laptop = {}

local desks = {}
desks["aai-signal-receiver"] = {x = 3.19921875, y = 3.17187500}
desks["aai-signal-sender"  ] = {x = 1.83984375, y = 1.12890625}

function laptop.init()
  storage.deathrattles = storage.deathrattles or {}

  for registration_number, child in pairs(storage.deathrattles) do
    child.destroy()
  end

  storage.deathrattles = {} -- effectively the same as setting each registration_number to nil, but this is just one call.

  for _, surface in pairs(game.surfaces) do
    for name, offset in pairs(desks) do
      for _, entity in pairs(surface.find_entities_filtered{name = name}) do
        laptop.register_desk(entity)
      end
    end
  end
end

function laptop.on_created_entity(event)
  local entity = event.entity or event.destination

  if desks[entity.name] then laptop.register_desk(entity) end
end

function laptop.register_desk(entity)
  local computer = laptop.create_laptop_on(entity, desks[entity.name])
end

function laptop.create_laptop_on(entity, offset)
  local computer = entity.surface.create_entity({
    name = "glutenfree-aai-signal-transmission-preview-laptop",
    force = entity.force,
    position = {entity.position.x + offset.x, entity.position.y + offset.y},
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = computer

  computer.operable = false
  computer.destructible = false

  local red_in = computer.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local green_in = computer.get_wire_connector(defines.wire_connector_id.circuit_green, true)

  red_in.connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
  green_in.connect_to(entity.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)

  return computer
end

function laptop.on_object_destroyed(event)
  if not storage.deathrattles[event.registration_number] then return end

  storage.deathrattles[event.registration_number].destroy()
  storage.deathrattles[event.registration_number] = nil
end


return laptop
