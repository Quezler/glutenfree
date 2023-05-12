local Handler = {}

function Handler.on_init(event)
  -- will not contain a freshly placed console until it has taken off at least once since built isn't raised (nor do i care to check for up to 60 ticks)
  global.spaceship_console_outputs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-console-output'})) do
      local spaceship_id = entity.get_or_create_control_behavior().get_signal(1).count
      global.spaceship_console_outputs[spaceship_id] = entity
    end
  end
end

-- track the spaceship console (output) to its new surface and ignoring/overriding the entry
function Handler.on_entity_cloned(event)
  local spaceship_id = event.destination.get_or_create_control_behavior().get_signal(1).count
  global.spaceship_console_outputs[spaceship_id] = event.destination
  -- game.print('cloned '.. spaceship_id .. ' to ' .. event.destination.surface.name)
  -- game.print('cloned at tick ' .. event.tick)
end

function Handler.on_tick(event)
  -- todo: there can be up to 10 seconds between on_surface_created and an automated launch actually happening,
  -- so we'll have to cache the area inside a global and like every second re-drain any of the nearby bots.
end

function Handler.on_surface_created(event)
  local surface = game.get_surface(event.surface_index)
  local _, _, num = string.find(surface.name, "^spaceship%-(%d+)$")
  local spaceship_id = tonumber(num)
  if not spaceship_id then return end -- the created surface was not for a launching spaceship
  -- game.print('a spaceship surface got created at tick ' .. event.tick)

  local entity = global.spaceship_console_outputs[spaceship_id]
  local tiles = entity.surface.get_connected_tiles(entity.position, {'se-spaceship-floor'})

  local min_x = nil
  local max_x = nil
  local min_y = nil
  local max_y = nil

  for _, tile in ipairs(tiles) do
    if min_x == nil or tile.x < min_x then min_x = tile.x end
    if max_x == nil or tile.x > max_x then max_x = tile.x end
    if min_y == nil or tile.y < min_y then min_y = tile.y end
    if max_y == nil or tile.y > max_y then max_y = tile.y end
  end

  max_x = max_x + 1 -- whole tile
  max_y = max_y + 1 -- whole tile

  -- expand area to include bots nearby the spaceship
  min_x = min_x - 10
  min_y = min_y - 10
  max_x = max_x + 10
  max_y = max_y + 10

  local area = {left_top = {x = min_x, y = min_y}, right_bottom={x = max_x, y = max_y}}

  local robots = entity.surface.find_entities_filtered{
    area = area,
    type = {'logistic-robot', 'construction-robot'},
  }

  -- game.print('#robots = ' .. #robots)

  for _, robot in ipairs(robots) do
    robot.energy = robot.energy * 0.1 -- drain immensely, through not completely so it still has some energy to dash to a nearby roboport
  end
end

script.on_init(Handler.on_init)

script.on_event(defines.events.on_tick, Handler.on_tick)
script.on_event(defines.events.on_surface_created, Handler.on_surface_created)

script.on_event(defines.events.on_entity_cloned, Handler.on_entity_cloned, {
  {filter = 'name', name = 'se-spaceship-console-output'},
})
