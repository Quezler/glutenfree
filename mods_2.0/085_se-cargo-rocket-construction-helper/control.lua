local silo = require('scripts.silo')

--

local function init()
  global = {}

  silo.init()
end

local function load()
  -- script.on_event(remote.call("glutenfree-rocket-silo-events", "on_rocket_silo_status_changed"), silo.on_rocket_silo_status_changed)
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

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, silo.on_created_entity, {
    {filter = "name", name = "se-rocket-launch-pad"},
  })
end


script.on_nth_tick(60 * 10, function()
  silo.every_10_seconds()
end)
