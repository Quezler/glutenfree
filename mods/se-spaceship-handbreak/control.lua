local Handler = {}

function Handler.on_init()
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-console'})) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity

  local position = {entity.position.x + (30 / 64), entity.position.y - (26 / 64)}
  local handbreak = entity.surface.find_entity('se-spaceship-handbreak', position)
  if not handbreak then
    handbreak = entity.surface.create_entity{
      name = 'se-spaceship-handbreak',
      force = 'neutral',
      position = position,
    }

    handbreak.destructible = false
    -- handbreak.operable = false -- todo: force wires to be reconnected when a spaceship changes surface

    handbreak.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="se-spaceship-launch"}, count = 0}}
    entity.connect_neighbour({target_entity = handbreak, wire = defines.wire_type.green})

    -- game.print('handbreak created')
  end
end

function Handler.on_player_rotated_entity(event)
  if event.entity.name ~= 'se-spaceship-handbreak' then return end
  -- game.print('handbreak rotated')

  if event.entity.direction == defines.direction.north or event.entity.direction == defines.direction.south then
    event.entity.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="se-spaceship-launch"}, count = 0}}
  elseif event.entity.direction == defines.direction.east or event.entity.direction == defines.direction.west then
    event.entity.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="se-spaceship-launch"}, count = -1}}
  else
    error('unexpected direction: ' .. event.entity.direction)
  end
end

function Handler.on_removed_entity(event)
  if event.entity and event.entity.valid then
    if event.entity.name == 'se-spaceship-console' then
      local position = {event.entity.position.x + (30 / 64), event.entity.position.y - (26 / 64)}
      local handbreak = event.entity.surface.find_entity('se-spaceship-handbreak', position)
      if handbreak then handbreak.destroy() end
    end
  end
end

--

script.on_init(Handler.on_init)

script.on_event(defines.events.on_built_entity, Handler.on_created_entity, {
  {filter = 'name', name = 'se-spaceship-console'},
})

script.on_event(defines.events.on_robot_built_entity, Handler.on_created_entity, {
  {filter = 'name', name = 'se-spaceship-console'},
})

script.on_event(defines.events.script_raised_built, Handler.on_created_entity, {
  {filter = 'name', name = 'se-spaceship-console'},
})

script.on_event(defines.events.script_raised_revive, Handler.on_created_entity, {
  {filter = 'name', name = 'se-spaceship-console'},
})

script.on_event(defines.events.on_player_rotated_entity, Handler.on_player_rotated_entity)

script.on_event(defines.events.on_entity_died, Handler.on_removed_entity)
script.on_event(defines.events.on_robot_mined_entity, Handler.on_removed_entity)
script.on_event(defines.events.on_player_mined_entity, Handler.on_removed_entity)
script.on_event(defines.events.script_raised_destroy, Handler.on_removed_entity)
