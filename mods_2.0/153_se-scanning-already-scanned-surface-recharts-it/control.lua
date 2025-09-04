local Zonelist = {
  action_scan_surface_button = "scan-surface",
}

script.on_event(defines.events.on_gui_click, function(event)
  if not event.element.valid then return end

  if event.element.tags.action == Zonelist.action_scan_surface_button then
    if event.element.tooltip[1] == "space-exploration.stop-scan-zone-button" then
      local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.element.tags.zone_index})
      local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

      -- recharts the surface, but also hidden chunks
      -- player.force.chart_all(player.surface.index)

      -- recharting only already charted chunks
      -- for chunk in player.surface.get_chunks() do
      --   if player.force.is_chunk_charted(player.surface, chunk) then
      --     player.force.chart(player.surface, chunk.area)
      --   end
      -- end

      -- the above but done on the c++ side instead
      player.force.rechart(zone.surface_index)
    end
  end
end)
