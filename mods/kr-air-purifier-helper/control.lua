local handler = require("scripts.kr-air-purifier")

--

local function init()
  handler.init()
end

local function load()
  for tick, _ in pairs(global.on_nth_ticks or {}) do
    script.on_nth_tick(tick, handler.on_nth_tick)
  end
end

script.on_init(function()
  init()
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
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
