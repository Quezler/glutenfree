local handler = require('scripts.handler')

--

local function init()
  -- handler.init()
end

local function load()
  -- script.on_event(remote.call("logistic-train-network", "on_stops_updated"), speaker.on_stops_updated)
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
  [defines.events.on_train_schedule_changed] = handler.on_train_schedule_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
