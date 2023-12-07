local Handler = {}

Handler.entity_name = 'se-interstellar-construction-requests-fulfillment--turret'

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  global.entities[entity.unit_number] = entity
end

function Handler.get_max_energy()
  if not Handler.max_energy then
    Handler.max_energy = game.entity_prototypes[Handler.entity_name].electric_energy_source_prototype.buffer_capacity
  end
  return Handler.max_energy
end

function Handler.tick(event)
  for unit_number, entity in pairs(global.entities) do
    if not entity.valid then
      global.entities[unit_number] = nil
    else
      game.print(entity.energy)
      if entity.energy == Handler.get_max_energy() then
        entity.energy = 0
      end
    end
  end
end

return Handler
