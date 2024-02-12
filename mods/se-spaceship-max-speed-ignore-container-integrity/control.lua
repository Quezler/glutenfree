commands.add_command('se-spaceship-max-speed-ignore-container-integrity', nil, function(command)
  local player = game.get_player(command.player_index)
  local surface = player.surface
  game.print(surface.name)

  if string.find(surface.name, "spaceship-") then
    local containers = surface.find_entities_filtered{type = {"container", "logistic-container"}}

    local ghosts = {} -- not actual ghosts, just a singular/prular combo that makes sense to be used within create_entity

    for _, container in ipairs(containers) do

      local inventory = container.get_inventory(defines.inventory.chest)
      local ghost = {
        name = container.name,
        force = container.force,
        position = container.position,

        inventory = game.create_inventory(#inventory),
      }

      for slot = 1, #inventory do
        inventory[slot].swap_stack(ghost.inventory[slot])
      end
      
      -- todo: save inventory
      -- todo: preserve wires
      -- todo: preserve signals

      container.destroy()
      table.insert(ghosts, ghost)
    end

    -- trigger Spaceship.on_entity_created(event)
    surface.create_entity{
      name = 'flying-text',
      position = {0, 0},
      text = {'achievement-name.so-long-and-thanks-for-all-the-fish'},
      raise_built = true,
    }

    for _, ghost in ipairs(ghosts) do
      local container = surface.create_entity{
        name = ghost.name,
        force = ghost.force,
        position = ghost.position,
      }

      local inventory = container.get_inventory(defines.inventory.chest)

      for slot = 1, #inventory do
        inventory[slot].swap_stack(ghost.inventory[slot])
      end

      ghost.inventory.destroy()
    end
  end
end)
