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
