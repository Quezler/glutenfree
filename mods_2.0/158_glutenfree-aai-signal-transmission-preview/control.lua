local handler = require("scripts.laptop")

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
  [defines.events.on_space_platform_built_entity] = handler.on_created_entity,
  [defines.events.on_robot_built_entity] = handler.on_created_entity,
  [defines.events.script_raised_built] = handler.on_created_entity,
  [defines.events.script_raised_revive] = handler.on_created_entity,
  [defines.events.on_entity_cloned] = handler.on_created_entity,

  [defines.events.on_object_destroyed] = handler.on_object_destroyed,
}

for event, callback in pairs(events) do
  script.on_event(event, callback)
end
