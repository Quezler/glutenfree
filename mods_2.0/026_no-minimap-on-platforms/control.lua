local setting_name_uninstalled = "no-minimap-on-platforms--uninstalled"

script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if settings.global[setting_name_uninstalled].value == true then return end
  player.game_view_settings.show_minimap = player.surface.platform == nil
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-global" then
    if event.setting == setting_name_uninstalled then
      if settings.global[setting_name_uninstalled].value then
        for _, player in pairs(game.players) do
          player.game_view_settings.show_minimap = true
        end
      end
    end
  end
end)
