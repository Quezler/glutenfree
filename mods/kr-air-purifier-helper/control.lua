local handler = require("scripts.kr-air-purifier")

--

local function init()
  global = {}

  handler.init()
end

script.on_init(function()
  init()
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
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

--

script.on_nth_tick(60 * 60 * 5, function()
  kr_air_purifier.every_five_minutes()
end)
