commands.add_command('se-spaceship-max-speed-ignore-container-integrity', nil, function(command)
  local player = game.get_player(command.player_index)
  local surface = player.surface
  game.print(surface.name)

  if string.find(surface.name, "spaceship-") then
    local containers = surface.find_entities_filtered{type = {"container", "logistic-container"}}
    for _, container in ipairs(containers) do
      -- todo: save inventory
      -- todo: preserve wires
      -- todo: preserve signals
      container.destroy()
    end

    -- trigger Spaceship.on_entity_created(event)
    surface.create_entity{
      name = 'flying-text',
      position = {0, 0},
      text = {'achievement-name.so-long-and-thanks-for-all-the-fish'},
      raise_built = true,
    }
  end
end)
