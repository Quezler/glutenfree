local Handler = require('scripts.handler')

local events = {
  -- [defines.events.on_built_entity]       = Handler.on_created_entity,
  -- [defines.events.on_robot_built_entity] = on_created_entity,
  -- [defines.events.script_raised_built]   = Handler.on_created_entity,
  -- [defines.events.script_raised_revive]  = on_created_entity,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end


script.on_event(defines.events.on_built_entity, Handler.on_created_entity, {
  {filter = 'name', name = 'entity-ghost'},
})

script.on_event(defines.events.script_raised_built, Handler.on_created_entity, {
  {filter = 'name', name = 'entity-ghost'},
})
