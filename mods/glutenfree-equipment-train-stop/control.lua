local handler = require('scripts.handler')

--

local function init()
  handler.init()
end

local function load()
  --
end

script.on_init(function()
  init()
  load()
end)

script.on_load(function()
  load()
end)

script.on_configuration_changed(function(event)
  init()
end)

--

local events = {
  [defines.events.on_built_entity] = handler.on_created_entity,
  [defines.events.on_robot_built_entity] = handler.on_created_entity,
  [defines.events.script_raised_built] = handler.on_created_entity,
  [defines.events.script_raised_revive] = handler.on_created_entity,
  [defines.events.on_entity_cloned] = handler.on_created_entity,

  [defines.events.on_entity_destroyed] = handler.on_entity_destroyed,
  [defines.events.on_tick] = handler.on_tick, -- todo: only have this handler active while global.tripwires_to_replace is not empty
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
