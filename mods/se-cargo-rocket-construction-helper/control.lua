local silo = require('scripts.silo')

--

local function init()
  global = {}

  log("init()")

  silo.init()
end

local function load()
  script.on_event(remote.call("glutenfree-rocket-silo-events", "on_rocket_silo_status_changed"), silo.on_rocket_silo_status_changed)
end

script.on_load(function()
  load()
end)

script.on_init(function()
  init()
  load()
end)

script.on_configuration_changed(function(event)
  init()
end)

--

local events = {
  [defines.events.on_built_entity] = silo.on_created_entity,
  [defines.events.on_robot_built_entity] = silo.on_created_entity,
  [defines.events.script_raised_built] = silo.on_created_entity,
  [defines.events.script_raised_revive] = silo.on_created_entity,
  [defines.events.on_entity_cloned] = silo.on_created_entity,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

script.on_nth_tick(60 * 10, function()
  silo.every_10_seconds()
end)
