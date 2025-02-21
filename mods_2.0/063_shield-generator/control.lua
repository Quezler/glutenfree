script.on_event(defines.events.on_tick, function(event)
  if not game.surfaces["fulgora"] then return end
  for _, player in ipairs(game.connected_players) do
    player.remove_alert{
      surface = "fulgora"
    }
  end
end)

commands.add_command("shield-generator", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local platform = player.surface.platform
  if not platform then return end

  for _, tile_position in ipairs(platform.surface.get_connected_tiles({0, 0}, {"space-platform-foundation"}, true)) do
    platform.surface.create_entity{
      name = "space-platform-foundation-protective-cover",
      force = "neutral",
      position = {tile_position.x + 0.5, tile_position.y + 0.5},
    }
  end
end)
