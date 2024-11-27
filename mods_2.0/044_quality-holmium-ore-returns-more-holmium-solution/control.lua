script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "holmium-solution-quality-multiplier" then
    player.cursor_stack.clear()
  end
end)
