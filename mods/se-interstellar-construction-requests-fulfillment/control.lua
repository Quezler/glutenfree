local Handler = require('scripts.handler')

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

script.on_init(Handler.on_init)

-- script.on_nth_tick(20, Handler.tick)

script.on_nth_tick(600 / 10, function(event)
  for _, player in ipairs(game.connected_players) do
    local alerts = player.get_alerts{
      type = defines.alert_type.no_material_for_construction,
    }

    for surface_index, surface_alerts in pairs(alerts) do
      for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
        Handler.handle_construction_alert(surface_alert)
      end
    end
  end
end)
