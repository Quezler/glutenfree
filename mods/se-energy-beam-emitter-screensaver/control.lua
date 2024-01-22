script.on_event(defines.events.on_gui_click, function(event)
  if event.element.type ~= 'camera' then return end

  local entity = event.element.entity
  if entity == nil then return end -- untargeted beam?
  if entity.name ~= 'se-energy-glaive-beam' then return end

  local player = game.get_player(event.player_index)
  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})

  -- opening the map right after remote view start does not cause the game to enter following map mode,
  -- so because i am lazy atm i will not delay it by one tick, but just prompt the user to double click.
  local second_click = player.surface == entity.surface

  remote.call("space-exploration", "remote_view_start", {player=player, zone_name = zone.name, position = entity.position, location_name="Doomwheel", freeze_history=true})
  player.open_map(entity.position, 1, entity)

  if second_click then
    player.opened = nil
  end
end)
