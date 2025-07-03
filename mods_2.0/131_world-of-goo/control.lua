commands.add_command("goo-balls", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local fishes = player.surface.find_entities_filtered{type = "fish"}
  game.print(#fishes)

  for _, fish in ipairs(fishes) do
    rendering.draw_sprite{
      surface = fish.surface,
      target = fish,
      sprite = "goo-ball",
      use_target_orientation = true,
      orientation_target = fish,
    }
  end
end)
