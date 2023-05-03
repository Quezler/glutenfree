local Handler = require('scripts.handler')

--

local events = {
  [defines.events.on_built_entity] = Handler.on_created_entity,
  [defines.events.on_robot_built_entity] = Handler.on_created_entity,
  [defines.events.script_raised_built] = Handler.on_created_entity,
  [defines.events.script_raised_revive] = Handler.on_created_entity,
  [defines.events.on_entity_cloned] = Handler.on_created_entity,

  [defines.events.on_entity_renamed] = Handler.on_entity_renamed,

  [defines.events.on_entity_destroyed] = Handler.on_entity_destroyed,
}

--

local function init()
  Handler.init()
end

local function load()
  for event, handler in pairs(events) do
    script.on_event(event, handler)
  end
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
