local handler = require('scripts.bubble')

--

local events = {
  [defines.events.on_train_schedule_changed] = handler.on_train_schedule_changed,
}

--

local function init()
  handler.init()
end

local function load()
  script.on_event(remote.call("logistic-train-network", "on_dispatcher_updated"), handler.on_dispatcher_updated)
  script.on_event(remote.call("logistic-train-network", "on_delivery_created"), handler.on_delivery_created)

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

--

script.on_nth_tick(60 * 60 * 10, function()
  handler.gc()
end)
