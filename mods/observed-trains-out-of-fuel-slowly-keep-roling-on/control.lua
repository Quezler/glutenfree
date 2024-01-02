script.on_nth_tick(600, function(event)
  local forces_checked = {}

  for _, player in ipairs(game.connected_players) do
    if not forces_checked[player.force.index] then

      if player.is_alert_enabled(defines.alert_type.train_out_of_fuel) then
        forces_checked[player.force.index] = true
        local alerts = player.get_alerts{
          type = defines.alert_type.train_out_of_fuel,
        }

        for surface_index, surface_alerts in pairs(alerts) do
          for _, surface_alert in ipairs(surface_alerts[defines.alert_type.train_out_of_fuel]) do
            if surface_alert.target and surface_alert.target.valid and surface_alert.target.unit_number then
              surface_alert.target.train.speed = math.max(surface_alert.target.train.speed, 0.1)
            end
          end
        end
      else
        player.enable_alert(defines.alert_type.train_out_of_fuel)
        -- command response for `/alerts enable train_out_of_fuel`
        player.print('Alert type train_out_of_fuel has been enabled.')
      end

    end -- if
  end -- for
end)
