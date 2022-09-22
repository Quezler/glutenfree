local handler = {}

local on_train_stop_trains_changed = script.generate_event_name()

remote.add_interface("glutenfree-train-stop-events", {
  on_train_stop_trains_changed = function() return on_train_stop_trains_changed end
})

--

function handler.init()
  
  -- keyed by .unit_number
  global.train_stops = {}

  -- keyed by .id
  global.trains = {} 
end

function handler.on_train_schedule_changed(event)
end

--

return handler
