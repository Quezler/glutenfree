local Handler = {}

function Handler.on_init()
  global.drop_positions = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-clamp'})) do
      Handler.tick_spaceship_clamp(entity)
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  game.print(entity.name)
  if entity.name ~= 'se-spaceship-clamp' then return end
  Handler.tick_spaceship_clamp(entity)
end

function Handler.tick_spaceship_clamp(entity)
  game.print('d ' .. entity.direction) -- 2> <0

  local position = {entity.position.x + 0.6, entity.position.y + 0.45}
  local fannypack = entity.surface.find_entity('logistic-robot-dropped-cargo', position)

  if not fannypack then
    fannypack = entity.surface.create_entity{
      name = "logistic-robot-dropped-cargo",
      position = position,
      force = entity.force
    }
    print('fannypack created for a clamp facing ' .. entity.direction)
  end
end

--

script.on_init(Handler.on_init)
-- script.on_event(defines.events.on_player_rotated_entity, Handler.on_player_rotated_entity)

script.on_event(defines.events.on_built_entity, Handler.on_created_entity)
script.on_event(defines.events.on_robot_built_entity, Handler.on_created_entity)
script.on_event(defines.events.script_raised_built, Handler.on_created_entity)
script.on_event(defines.events.script_raised_revive, Handler.on_created_entity)
script.on_event(defines.events.on_entity_cloned, Handler.on_created_entity)

-- script.on_nth_tick(60 * 60, Handler.on_nth_tick) -- every 60 seconds
