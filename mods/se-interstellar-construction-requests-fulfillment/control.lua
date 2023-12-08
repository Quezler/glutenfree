local Handler = require('scripts.handler')

script.on_init(Handler.on_init)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = 'name', name = 'se-interstellar-construction-requests-fulfillment--turret'},
  })
end

script.on_event(defines.events.on_entity_destroyed, Handler.on_entity_destroyed)

script.on_nth_tick(600, function(event) -- no_material_for_construction expires after 10 seconds
  local forces_checked = {}
  for _, player in ipairs(game.connected_players) do
    if not forces_checked[player.force.index] then 
      forces_checked[player.force.index] = true
      local alerts = player.get_alerts{
        type = defines.alert_type.no_material_for_construction,
      }

      for surface_index, surface_alerts in pairs(alerts) do
        for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
          Handler.handle_construction_alert(surface_alert)
        end
      end
    end
  end
end)

script.on_nth_tick(60 * 60 * 10, Handler.gc) -- every 10 minutes

commands.add_command('se-interstellar-construction-requests-fulfillment', nil, function(command)
  game.print(serpent.block({
    table_size(global.structs),
    #global.deck,
    #global.pile,
  }))
end)
