local human_direction = {
  [defines.direction.north] = 'north',
  [defines.direction.east] = 'east',
  [defines.direction.south] = 'south',
  [defines.direction.west] = 'west',
}

local util = require('util')

commands.add_command('loader-through-spaceship-wall', nil, function(command)
  local player = assert(game.get_player(command.player_index))

  local selected = player.selected
  if selected == nil then return end
  if selected.name ~= 'kr-se-loader' then return end

  local surface = selected.surface
  local direction = selected.loader_type == "input" and selected.direction or util.oppositedirection(selected.direction)
  game.print(human_direction[direction])

  local try_container_at = util.moveposition({selected.position.x, selected.position.y}, direction, 2)

  rendering.draw_circle{
    color = {1, 1, 1},
    radius = 0.1,
    filled = true,
    surface = surface,
    target = try_container_at,
    time_to_live = 60,
  }

  local containers = surface.find_entities_filtered{
    position = try_container_at,
    type = {'container', 'logistic_container'},
    force = selected.force,
    limit = 1,
  }

  if #containers == 0 then return end
  local container = containers[1]

  container.teleport(util.moveposition({container.position.x, container.position.y}, direction, -1))
  selected.update_connections()
  container.teleport(util.moveposition({container.position.x, container.position.y}, direction,  1))
end)
