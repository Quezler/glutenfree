-- local util = require('util')

local Handler = {}

function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if entity.name == 'big-electric-pole-roboport' then
    entity.destroy() -- other mods are not allowed to create instances
    return
  end

  if global.deactivated then return end

  -- saninty check to make sure there is not already a roboport here
  assert(entity.surface.find_entity('big-electric-pole-roboport', entity.position) == nil)

  entity.surface.create_entity{
    name = 'big-electric-pole-roboport',
    force = entity.force,
    position = {entity.position.x, entity.position.y + 0.01}
  }
end

function Handler.activate()
  game.print('activated')
  global.deactivated = false

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'big-electric-pole'}})) do
      on_created_entity({entity = entity})
    end
  end
end

function Handler.deactivate()
  game.print('deactivated')
  global.deactivated = true

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'big-electric-pole-roboport'}})) do
      entity.destroy()
    end
  end
end

function Handler.check_technology_for_roboport(technology)
  for _, effect in ipairs(technology.effects) do
    if effect.type == 'unlock-recipe' and effect.recipe == 'roboport' then
      Handler.activate()
      return
    end
  end
end

script.on_event(defines.events.on_research_finished, function (event)
  if not global.deactivated then return end
  Handler.check_technology_for_roboport(event.research)
end)

script.on_init(function(event)
  global.deactivated = true

  -- Handler.activate()
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'big-electric-pole'},
    {filter = 'name', name = 'big-electric-pole-roboport'},
  })
end
