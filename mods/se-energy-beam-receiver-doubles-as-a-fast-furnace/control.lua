local mod = {}

function mod.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local furnace = entity.surface.create_entity{
    name = 'se-energy-receiver-electric-furnace',
    force = entity.force,
    position = {entity.position.x, entity.position.y - 2.5},
  }

  furnace.destructible = false

  local struct = {
    unit_number = entity.unit_number,

    reactor = entity,
    furnace = furnace,

    temperature = 0,
  }

  global.structs[entity.unit_number] = struct
  mod.update_struct(struct)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = 'name', name = 'se-energy-receiver'},
  })
end

script.on_init(function(event)
  global.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'se-energy-receiver'}})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

function mod.update_struct(struct)
  if struct.reactor.valid == false then
    struct.furnace.destroy()
    global.structs[struct.unit_number] = nil
    return
  end

  local old_count = struct.furnace.get_fluid_count('se-energy-receiver-electric-furnace-fluid')
  game.print(old_count - struct.temperature) -- -0.002 means it was active for that entire second
  struct.furnace.clear_fluid_inside()
  
  struct.temperature = struct.reactor.temperature
  struct.furnace.insert_fluid({name = 'se-energy-receiver-electric-furnace-fluid', amount = struct.temperature, temperature = struct.temperature})
end

function mod.on_tick(event)
  for unit_number, struct in pairs(global.structs) do
    if (event.tick + unit_number) % 60 == 0 then
      mod.update_struct(struct)
    end
  end
end

script.on_event(defines.events.on_tick, mod.on_tick)
