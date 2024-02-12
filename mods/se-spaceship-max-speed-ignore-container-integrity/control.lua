local Spaceship = require('__space-exploration-scripts__.spaceship')

-- we need to know when the spaceship is done with the integrity check, since "stop" calls Spaceship.check_integrity_stress(spaceship),
-- the trick we will use is creating entities on created tiles that will be destroyed by the `entity.damage(150` detatched tiles mechanic,
-- once those entities get destoyed its a pretty fair bet that in the next tick the spaceship's integrity is valid and completely done.
local function register_on_integrity_check_passed_event(surface)
  local tiles = {}

  for _, entity in ipairs(surface.find_entities_filtered{name = Spaceship.names_engines}) do
    local box = entity.bounding_box
    local engine_y = math.floor(box.right_bottom.y) + 1
    local engine_x = math.floor((box.left_top.x + box.right_bottom.x) / 2)

    -- 2 tiles under even width engines, and 1 tile under odd width engines
    if entity.position.x % 1 < 0.25 or entity.position.x % 1 > 0.75 then
      table.insert(tiles, {x = engine_x - 1, y = engine_y})
    end
    table.insert(tiles, {x = engine_x, y = engine_y})
  end

  for _, position in ipairs(tiles) do
    surface.create_entity{
      name = 'small-lamp',
      position = position,
    }
  end
end

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

    register_on_integrity_check_passed_event(surface)

    -- for _, ghost in ipairs(ghosts) do
    --   local container = surface.create_entity{
    --     name = ghost.name,
    --     force = ghost.force,
    --     position = ghost.position,
    --   }

    --   local inventory = container.get_inventory(defines.inventory.chest)

    --   for slot = 1, #inventory do
    --     inventory[slot].swap_stack(ghost.inventory[slot])
    --   end

    --   ghost.inventory.destroy()
    -- end
  end
end)
