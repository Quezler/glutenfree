function on_entity_created(event)
  local entity = event.created_entity or event.entity
  if not entity.valid then return end

  if entity.name ~= 'se-core-miner-drill' then return end

  local chest = entity.surface.find_entity('se-core-miner-drill-linked-container', entity.position)
  if not chest then
    chest = entity.surface.create_entity{
      name = 'se-core-miner-drill-linked-container',
      force = entity.force,
      position = entity.position,
    }
  
    chest.destructible = false
    chest.link_id = entity.surface.index
  end

  entity.drop_target = chest
end

script.on_init(function(event)
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-core-miner-drill'})) do
      on_entity_created({entity = entity})
    end
  end
end)

script.on_event(defines.events.on_built_entity,       on_entity_created, {{filter = 'name', name = 'se-core-miner-drill'}})
script.on_event(defines.events.on_robot_built_entity, on_entity_created, {{filter = 'name', name = 'se-core-miner-drill'}})
script.on_event(defines.events.script_raised_built,   on_entity_created, {{filter = 'name', name = 'se-core-miner-drill'}})
script.on_event(defines.events.script_raised_revive,  on_entity_created, {{filter = 'name', name = 'se-core-miner-drill'}})

-- rotating would dislodge the drop_target because of the `no-automated-item-insertion` tag
script.on_event(defines.events.on_player_rotated_entity, on_entity_created)
