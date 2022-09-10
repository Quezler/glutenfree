local poles = require('scripts.poles')

--

local function init()
  log("init")
  global = {}

  poles.init()
end

script.on_init(init)
script.on_configuration_changed(init)

--

local events = {
  [defines.events.on_built_entity] = poles.on_created_entity,
  [defines.events.on_robot_built_entity] = poles.on_created_entity,
  [defines.events.script_raised_built] = poles.on_created_entity,
  [defines.events.script_raised_revive] = poles.on_created_entity,
  [defines.events.on_entity_cloned] = poles.on_created_entity,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

--

