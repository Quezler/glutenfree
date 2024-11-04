script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  if player.selected and player.selected.name == "alchemical-combinator" then
    player.play_sound{
      path = "alchemical-combinator-charge",
      position = player.selected.position,
    }
  end

  if event.last_entity and event.last_entity.name == "alchemical-combinator" then
    player.play_sound{
      path = "alchemical-combinator-uncharge",
      position = event.last_entity.position,
    }
  end
end)
