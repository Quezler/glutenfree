local ltn = require('scripts.ltn')
local trains = require('scripts.train')
local combinator = require('scripts.combinator')

local speaker = {}

--

function speaker.init()
  storage.on_nth_ticks = nil

  storage.entries = {}
  storage.deathrattles = storage.deathrattles or {}

  storage.deliveries = {}
  storage.logistic_train_stops = {}
  storage.deliveries_table_was_previously_empty = true

  --

  storage.train_stops = nil
  storage.train_stop_at = nil

  --

  storage.entangled = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'train-stop', name = 'logistic-train-stop'}) do
      speaker.add_speaker_to_ltn_stop(entity) -- resets any signals to their default until the the next dispatch
    end
  end

end

function speaker.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'logistic-train-stop' then return end

  speaker.add_speaker_to_ltn_stop(entity)
end

function speaker.add_speaker_to_ltn_stop(entity)
  local speakerpole = nil

  local multiblock = entity.surface.find_entities(ltn.search_area(entity))

  for _, mb_entity in ipairs(multiblock) do
    if mb_entity.name == "entity-ghost" then
      if mb_entity.ghost_name == 'logistic-train-stop-announcer' then
        _, speakerpole = mb_entity.revive()
        break
      end
    else
      if mb_entity.name == 'logistic-train-stop-announcer' then
        speakerpole = mb_entity
        break
      end
    end
  end

  speakerpole = speakerpole or entity.surface.create_entity({
    name = 'logistic-train-stop-announcer',
    position = ltn.pos_for_speaker(entity),
    force = entity.force,
  })

  speakerpole.operable = false
  speakerpole.destructible = false

  -- mark speaker pole for death if the station dissapears
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {speakerpole}

  local red_signal = speakerpole.surface.find_entity('logistic-train-stop-announcer-red-signal', speakerpole.position) or
  speakerpole.surface.create_entity({
    name = 'logistic-train-stop-announcer-red-signal',
    position = speakerpole.position,
    force = speakerpole.force,
  })

  local green_signal = speakerpole.surface.find_entity('logistic-train-stop-announcer-green-signal', speakerpole.position) or
  speakerpole.surface.create_entity({
    name = 'logistic-train-stop-announcer-green-signal',
    position = speakerpole.position,
    force = speakerpole.force,
  })

  red_signal.operable = false
  green_signal.operable = false

  -- mark both color combinators for death if the speaker pole dissapears
  storage.deathrattles[script.register_on_object_destroyed(speakerpole)] = {red_signal, green_signal}

  local red_wire = speakerpole.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local green_wire = speakerpole.get_wire_connector(defines.wire_connector_id.circuit_green, true)

  red_wire.connect_to(red_signal.get_wire_connector(defines.wire_connector_id.circuit_red), false, defines.wire_origin.script)
  green_wire.connect_to(green_signal.get_wire_connector(defines.wire_connector_id.circuit_green), false, defines.wire_origin.script)

  storage.entries[entity.unit_number] = {
    speakerpole = speakerpole,
    red_signal = red_signal,
    green_signal = green_signal,
  }

  red_signal.get_control_behavior().sections[1].filters = {}
  green_signal.get_control_behavior().sections[1].filters = {}
end

-- conveniently gets called when a temporary schedule gets removed,
-- and since we want to remove the 'announcement' when the train arrives,
-- we just have to check which station the train is at when it gets taken off.
function speaker.on_train_schedule_changed(event)
  -- game.print("schedule changed @ " .. event.tick)

  if not storage.deliveries then return end -- ltn event race condition
  if not storage.entangled then return end -- ltn event race condition

  -- filter out this train id during debugging
  -- if event.train.id ~= 1236 then return end (nauvis stone)
  -- if event.train.id ~= 4748 then return end (thermofluid)

  local already_updated = {}

  -- update all the stations where this train caused red/green signals ^-^
  for _, station in ipairs(trains.entangled_with_stations(event.train)) do
    speaker.announce(station)
    already_updated[station.unit_number] = true
  end

  -- not an LTN train, or delivery not yet registered here
  if not storage.deliveries[event.train.id] then return end
  local delivery = storage.deliveries[event.train.id]

  local provider = storage.logistic_train_stops[delivery.from_id]
  if provider and provider.entity.valid and not already_updated[provider.entity.unit_number] then speaker.announce(provider.entity) end

  local requester = storage.logistic_train_stops[delivery.to_id]
  if requester and requester.entity.valid and not already_updated[requester.entity.unit_number] then speaker.announce(requester.entity) end
end

-- update the speakerpole signals
function speaker.announce(entity)
  local entry = storage.entries[entity.unit_number]
  if not entry then return end

  local red = {}
  local green = {}

  -- entity.surface.create_entity({
  --   name = "flying-text",
  --   position = entity.position,
  --   text = "announcing:",
  -- })

  for _, train in ipairs(entity.get_train_stop_trains()) do

    local delivery = storage.deliveries[train.id]
    if delivery then

      -- is the train still [underway] to here?
      if trains.is_inbound(train, entity) then

        -- sum any/all the items due for pickup
        if delivery.from_id == entity.unit_number then
          for what, count in pairs(delivery.shipment) do
            red[what] = (red[what] or 0) + count
          end
          trains.entangle_with_station(train, entity)
        end

        -- sum any/all the items due for dropoff
        if delivery.to_id == entity.unit_number then
          for what, count in pairs(delivery.shipment) do
            green[what] = (green[what] or 0) + count
          end
          trains.entangle_with_station(train, entity)
        end
      end

    end
  end

  -- print(serpent.block({
  --   red = red,
  --   green = green,
  -- }))

  if entry.red_signal.valid then
    entry.red_signal.get_control_behavior().sections[1].filters = combinator.filters_from_shipment(red)
  else
    game.print('red signal no longer valid: ' .. entity.unit_number .. serpent.line(entity.position))
  end

  if entry.green_signal.valid then
    entry.green_signal.get_control_behavior().sections[1].filters = combinator.filters_from_shipment(green)
  else
    game.print('green signal no longer valid: ' .. entity.unit_number .. serpent.line(entity.position))
  end
end

function speaker.on_object_destroyed(event)
  if not storage.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(storage.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  storage.deathrattles[event.registration_number] = nil
end

-- <ltn events>
function speaker.on_stops_updated(event)
  -- print('on_stops_updated_event @ ' .. event.tick)
  storage.logistic_train_stops = event.logistic_train_stops
end

function speaker.on_dispatcher_updated(event)
  -- game.print('on_dispatcher_updated @ ' .. event.tick)
  storage.deliveries = event.deliveries

  if storage.deliveries_table_was_previously_empty then
    storage.deliveries_table_was_previously_empty = false

    -- we now have all deliveries, update all trains:
    for train_id, delivery in pairs(storage.deliveries) do
      speaker.on_train_schedule_changed({train = delivery.train})
    end
  else
    for _, train_id in pairs(event.new_deliveries) do
      if storage.deliveries[train_id].train.valid then
        speaker.on_train_schedule_changed(storage.deliveries[train_id])
      end
    end
  end
end

-- </ltn events>

-- garbage collection
function speaker.every_10_minutes()
  for unit_number, entry in pairs(storage.entries or {}) do
    if not entry.speakerpole.valid then
      storage.entries[unit_number] = nil
    elseif not game.get_entity_by_unit_number(unit_number) then
      storage.entries[unit_number] = nil
      entry.speakerpole.destroy()
    end
  end
end

return speaker
