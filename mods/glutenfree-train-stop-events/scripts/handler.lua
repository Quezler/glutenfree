local handler = {}

local on_train_stop_trains_changed = script.generate_event_name()
local on_train_removed_from_train_stop = script.generate_event_name()

remote.add_interface("glutenfree-train-stop-events", {
  on_train_stop_trains_changed = function() return on_train_stop_trains_changed end
})

--

function handler.init()
  
  -- keyed by .unit_number
  global.train_stops = {}

  -- keyed by .id
  global.trains = {}

  global.

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'train-stop'}) do
      handler.register_train_stop(entity)
    end

    for _, train in ipairs(surface.get_trains()) do
      handler.register_train(train)
    end
  end
end

function handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.type ~= 'train-stop' then return end

  handler.register_train_stop(entity)
end

function handler.register_train_stop(entity)
  global.train_stops[entity.unit_number] = entity
end

function handler.register_train(train)
  global.trains[train.id] = train
end

function handler.on_train_schedule_changed(event)
end

--

return handler
