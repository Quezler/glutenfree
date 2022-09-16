
local speaker = require('scripts.speaker')

--

local function init()
  global = {}
  speaker.init()
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
  [defines.events.on_built_entity] = speaker.on_created_entity,
  [defines.events.on_robot_built_entity] = speaker.on_created_entity,
  [defines.events.script_raised_built] = speaker.on_created_entity,
  [defines.events.script_raised_revive] = speaker.on_created_entity,
  [defines.events.on_entity_cloned] = speaker.on_created_entity,
  
  [defines.events.on_train_schedule_changed] = speaker.on_train_schedule_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

-- script.on_nth_tick(60 * 10, function()
--   silo.every_10_seconds()
-- end)
