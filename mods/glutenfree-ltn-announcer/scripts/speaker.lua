local ltn = require('scripts.ltn')

local speaker = {}

function speaker.init()
  global.entries = {}

  global.deathrattles = global.deathrattles or {}

  global.deliveries = global.deliveries or {}
  global.logistic_train_stops = global.logistic_train_stops or {}

  global.train_stops = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "train-stop"}) do
      global.train_stops[entity.unit_number] = entity

      if entity.name == 'logistic-train-stop' then
        speaker.add_speaker_to_ltn_stop(entity)
      end
    end
  end
end

function speaker.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'logistic-train-stop' then return end

  speaker.add_speaker_to_ltn_stop(entity)
end

function speaker.add_speaker_to_ltn_stop(entity)

  local multiblock = entity.surface.find_entities(ltn.search_area(entity))
  for _, e in ipairs(multiblock) do
    if e.name == "entity-ghost" then
      game.print(e.ghost_name)
    else
      game.print(e.name)
    end
  end

  -- entity.surface.create_entity({
  --   name = "highlight-box",
  --   box_type = "train-visualization",
  --   position = entity.position,
  --   bounding_box = ltn.search_area(entity),
  --   time_to_live = 60 * 2,
  -- })

  local stop = entity
  local entity = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer',
    position = ltn.pos_for_speaker(entity),
    force = entity.force,
  })

  -- mark speaker pole for death if the station dissapears
  global.deathrattles[script.register_on_entity_destroyed(stop)] = {entity}

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

  -- mark both color combinators for death if the speaker pole dissapears
  global.deathrattles[script.register_on_entity_destroyed(entity)] = {red_signal, green_signal}

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

function speaker.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

return speaker
