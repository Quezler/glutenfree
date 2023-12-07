script.on_init(function(event)
  global.entities = {}
end)

function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  global.entities[entity.unit_number] = entity
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-interstellar-construction-requests-fulfillment--turret'},
  })
end

script.on_nth_tick(60, function(event)
  for unit_number, entity in pairs(global.entities) do
    game.print(entity.energy)
    game.print(game.entity_prototypes[entity.name].electric_energy_source_prototype.buffer_capacity)
  end
end)

script.on_nth_tick(600, function(event)

  for _, player in ipairs(game.connected_players) do
    local alerts = player.get_alerts{
      type = defines.alert_type.no_material_for_construction,
    }

    for surface_index, surface_alerts in pairs(alerts) do
      for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
        -- {
        --   {
        --     count = 1,
        --     name = "industrial-furnace"
        --   }
        -- ...
        -- }
        -- {
        --   {
        --     count = 1,
        --     name = "storage-tank"
        --   }
        -- }
        log(serpent.block(surface_alert.target.ghost_prototype.items_to_place_this))
      end
    end
  end

end)
