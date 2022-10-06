function listen()
  script.on_event(remote.call("glutenfree-circuit-network-events", "on_circuit_condition_fulfilled_event"), on_circuit_condition_fulfilled_event)
end

script.on_init(function()
  global.consoles = {}

  listen()
end)

script.on_load(function()
  listen()
end)

--

function listen_for_the_next_pulse(entity)
    -- https://lua-api.factorio.com/latest/Concepts.html#WireConnectionDefinition
    local registration_number = remote.call("glutenfree-circuit-network-events", "register_on_circuit_condition_fulfilled", {
      wire = defines.wire_type.red,    
      target_entity = entity,
      condition = { -- https://lua-api.factorio.com/latest/Concepts.html#CircuitCondition
        comparator = '>=',
        -- first_signal = {type = 'virtual', name = 'se-spaceship-launch'},
        first_signal = {type = 'item', name = 'small-lamp'},
        constant = 1,
      }
    })
  
    global.consoles[registration_number] = entity
end


-- you should listen to all 5 build related events, but for the purpose of this demo only the player build event is hooked.
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.created_entity
  if entity.name ~= 'se-spaceship-console' then return end

  listen_for_the_next_pulse(entity)
end)

function on_circuit_condition_fulfilled_event(event)
  local entity = global.consoles[event.registration_number]
  if entity then global.consoles[event.registration_number] = nil
    entity.surface.create_entity({name = "flying-text", position = entity.position, text = 'i have received the launch signal'})

    -- ideally you would keep track of a toggle state or it runs each tick if it is sustained (aka: register the next event with a '< 1' comparator)
    listen_for_the_next_pulse(entity)
  end
end
