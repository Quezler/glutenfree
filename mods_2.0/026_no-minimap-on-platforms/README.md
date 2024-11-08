```lua
script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.game_view_settings.show_minimap = player.surface.platform == nil
end)
```
