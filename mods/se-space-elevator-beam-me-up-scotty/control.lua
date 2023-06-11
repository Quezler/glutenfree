local _global = {} -- it all happens in the same tick

script.on_event(defines.events.on_gui_click, function(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element

  if element.name == "travel" then
    -- game.print("15 bleh bleh bleh")

    -- ignoring completed initial construction
    -- ignoring not enough parts for player travel
    -- ignoring not enough energy for player travel
    
    local player = game.get_player(event.player_index)
    assert(player.opened.name == "se-space-elevator")

    -- {"space-exploration.space-elevator-travel-failed-remote-view"}
    if remote.call("space-exploration", "remote_view_is_active", {player=player}) then return end
    -- INBF you can select a space elevator in remote view, return to normal mode & then teleport

    _global[player.index] = {
      tick = event.tick,
      position = player.position,
    }

    player.teleport(player.opened.position)
  end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  local entry = _global[event.player_index]
  if entry then _global[event.player_index] = nil
    if entry.tick == game.tick then
      local player = game.get_player(event.player_index)
      player.teleport(entry.position)
    end
  end
end)
