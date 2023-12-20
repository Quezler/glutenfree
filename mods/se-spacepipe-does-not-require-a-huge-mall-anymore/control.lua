local map = {
  ["se-space-pipe-long-j-3" ] = 2,
  ["se-space-pipe-long-j-5" ] = 3,
  ["se-space-pipe-long-j-7" ] = 4,
  ["se-space-pipe-long-s-9" ] = 5,
  ["se-space-pipe-long-s-15"] = 8,
}

script.on_event(defines.events.on_player_pipette, function(event)
  local player = game.get_player(event.player_index)
  local selected = player.selected

  if not selected then return end
  local name = selected.name == "entity-ghost" and selected.ghost_name or selected.name
  if not map[name] then return end

  player.clear_cursor() -- can be false
  player.cursor_ghost = name -- doesn't put any items from the inventory into the hand tho
end)
