local ltn = require('scripts.ltn')

local speaker = {}

function speaker.init()
  global.entries = {}

  global.deliveries = global.deliveries or {}
  global.logistic_train_stops = global.logistic_train_stops or {}
end

function speaker.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'logistic-train-stop' then return end

  local entity = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer',
    position = ltn.pos_for_speaker(entity),
    force = entity.force,
  })

  entity.operable = false
  entity.destructible = false

  local red_signal = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer-red-signal',
    position = entity.position,
    force = entity.force,
  })

  local green_signal = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer-green-signal',
    position = entity.position,
    force = entity.force,
  })

  entity.connect_neighbour({
    target_entity = red_signal,
    wire = defines.wire_type.red,
  })

  entity.connect_neighbour({
    target_entity = green_signal,
    wire = defines.wire_type.green,
  })

  -- here entity is the speaker pole
  global.entries[entity.unit_number] = {
    entity = entity,
    red_signal = red_signal,
    green_signal = green_signal, 
  }

  red_signal.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-red"}, count = 1 }}
  green_signal.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-green"}, count = 1 }}
  
end

function speaker.on_train_schedule_changed(event)

  -- is an LTN train between dispatched and delivery state
  if not global.deliveries[event.train.id] then return end

  print('schedule + delivery:')
  print(serpent.block( event.train.schedule ))
  print(serpent.block( global.deliveries[event.train.id] ))
end

function speaker.on_dispatcher_updated(event)
  print('on_dispatcher_updated @ ' .. event.tick)
  global.deliveries = event.deliveries
end

function speaker.on_stops_updated(event)
  print('on_stops_updated_event @ ' .. event.tick)
  global.logistic_train_stops = event.logistic_train_stops
end

return speaker
