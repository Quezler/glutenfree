script.on_event('open-fluid-wagon', function(event)
  local player = game.get_player(event.player_index)

  local selected = player.selected
  if selected == nil then return end
  if selected.type ~= 'fluid-wagon' then return end

  game.print(selected.name)
end)
