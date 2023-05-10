local Handler = {}

function Handler.on_init()
  -- global.deathrattle = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-console'})) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity

  local position = {entity.position.x + (15 / 32), entity.position.y - (11 / 32)}

  local handbreak = entity.surface.find_entity('se-spaceship-handbreak', position)
  if not handbreak then
    handbreak = entity.surface.create_entity{
      name = 'se-spaceship-handbreak',
      force = 'neutral',
      position = position,
    }

    handbreak.destructible = false

    game.print('handbreak created')
    -- global.deathrattles[script.register_on_entity_destroyed(entity)] = {console = entity, juicebox = juicebox}
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
