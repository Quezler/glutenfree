local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local furnace = entity.surface.create_entity{
    name = 'se-energy-receiver-electric-furnace',
    force = entity.force,
    position = {entity.position.x, entity.position.y - 2.5},
  }

  furnace.destructible = false

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,

    reactor = entity,
    furnace = furnace,
  }

  furnace.insert_fluid({name = 'se-energy-receiver-electric-furnace-fluid', amount = 1000})
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-energy-receiver'},
  })
end

script.on_init(function(event)
  global.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'se-energy-receiver'}})) do
      on_created_entity({entity = entity})
    end
  end
end)
