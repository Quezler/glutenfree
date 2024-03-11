script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == 'lua-combinator' then
    -- close this gui and open a lua one, or attach to player.gui.relative
  end
end)

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  
  entity.active = false
  
  local combinator = entity.surface.find_entity('lua-combinator-internal', entity.position)
  if combinator == nil then
    combinator = entity.surface.create_entity{
      name = 'lua-combinator-internal',
      force = entity.force,
      position = entity.position,
    }

    combinator.destructible = false

    combinator.connect_neighbour({
      target_entity = entity,
      wire = defines.wire_type.red,
      target_circuit_id = defines.circuit_connector_id.combinator_output,
    })
    combinator.connect_neighbour({
      target_entity = entity,
      wire = defines.wire_type.green,
      target_circuit_id = defines.circuit_connector_id.combinator_output,
    })

    global.children[script.register_on_entity_destroyed(entity)] = combinator
  end

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
    internal = combinator,
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'lua-combinator'},
  })
end

local function on_configuration_changed()
  global.structs = global.structs or {}
  global.children = global.children or {}
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function tick_combinator(struct)
  local parameters = {}

  -- just use entity.get_merged_signal(s) if you don't care about seperate input wires.

  local red_network = struct.entity.get_circuit_network(defines.wire_type.red, defines.circuit_connector_id.combinator_input)
  local green_network = struct.entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)

  if red_network and red_network.signals then
    for _, signal in ipairs(red_network.signals) do
      table.insert(parameters, {
        signal = signal.signal, count = signal.count * 10, index = #parameters + 1,
      })
    end
  end

  if green_network and green_network.signals then
    for _, signal in ipairs(green_network.signals) do
      table.insert(parameters, {
        signal = signal.signal, count = signal.count / 10, index = #parameters + 1,
      })
    end
  end

  table.insert(parameters, {
    signal = {type = 'item', name = 'raw-fish'}, count = 1, index = #parameters + 1,
  })

  struct.internal.get_control_behavior().parameters = parameters
end

script.on_nth_tick(60, function(event)
  for unit_number, struct in pairs(global.structs) do
    if struct.entity.valid then
      tick_combinator(struct)
    else
      global.structs[unit_number] = nil
    end
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local child = global.children[event.registration_number]
  if child then global.children[event.registration_number] = nil
    child.destroy()
  end
end)
