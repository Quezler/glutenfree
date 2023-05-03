local Handler = {}

function Handler.init()
  global.deathrattle = {}

  global.backer_names = {}
  for _, name in pairs(game.backer_names) do
    global.backer_names[name] = true
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'train-stop', name = 'logistic-train-stop'}) do
      Handler.add_combinator_to_ltn_stop(entity)
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'logistic-train-stop' then return end

  Handler.add_combinator_to_ltn_stop(entity)
end

function Handler.add_combinator_to_ltn_stop(entity)
  local combinator = entity.surface.find_entity('red-signal-on-backer-name-combinator', entity.position)
  if not combinator then
    combinator = entity.surface.create_entity({
      name = 'red-signal-on-backer-name-combinator',
      position = entity.position,
      force = entity.force,
    })
    -- game.print('red combinator +')
  end
  
  global.deathrattle[script.register_on_entity_destroyed(entity)] = combinator

  -- entity.connect_neighbour({target_entity = combinator, wire = defines.wire_type.red})
  -- entity.connect_neighbour({target_entity = combinator, wire = defines.wire_type.green})

  combinator.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-red"}, count = 1}}

  Handler.on_entity_renamed({entity = entity})
end

function Handler.on_entity_renamed(event)
  local entity = event.entity
  if entity.name ~= 'logistic-train-stop' then return end

  local combinator = entity.surface.find_entity('red-signal-on-backer-name-combinator', entity.position)

  if global.backer_names[entity.backer_name] then
    entity.connect_neighbour({target_entity = combinator, wire = defines.wire_type.red})
    
    local circuit = entity.get_control_behavior()
    circuit.enable_disable = true
    circuit.circuit_condition = {condition = {
      comparator = '=',
      constant = 0,
      first_signal = {
        name = 'signal-red',
        type = 'virtual',
      }
    }}

    -- combinator.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-red"}, count = 1}}
  else
    entity.disconnect_neighbour({target_entity = combinator, wire = defines.wire_type.red})
    -- combinator.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-red"}, count = 0}}
  end
end

function Handler.on_entity_destroyed(event)
  if global.deathrattle[event.registration_number] then
    global.deathrattle[event.registration_number].destroy()
    global.deathrattle[event.registration_number] = nil
    -- game.print('red combinator -')
  end
end

return Handler
