local labs = require('scripts.labs')

--

local function init()
  global = {}

  log("init()")
  labs.init()
end

script.on_init(init)
script.on_configuration_changed(init)

--

local events = {
  [defines.events.on_built_entity] = labs.on_created_entity,
  [defines.events.on_robot_built_entity] = labs.on_created_entity,
  [defines.events.script_raised_built] = labs.on_created_entity,
  [defines.events.script_raised_revive] = labs.on_created_entity,
  [defines.events.on_entity_cloned] = labs.on_created_entity,

  [defines.events.on_entity_destroyed] = labs.on_entity_destroyed,
  [defines.events.on_research_started] = labs.on_research_changed,
  [defines.events.on_research_finished] = labs.on_research_changed,
  [defines.events.on_research_cancelled] = labs.on_research_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

--

script.on_nth_tick(settings.startup["lab-resupply-interval"].value, labs.every_minute)
