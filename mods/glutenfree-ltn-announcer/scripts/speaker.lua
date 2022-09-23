local util = require('util')

local ltn = require('scripts.ltn')
local trains = require('scripts.train')
local combinator = require('scripts.combinator')

local speaker = {}

--

function speaker.init()
  global.on_nth_ticks = nil

  global.entries = {}
  global.deathrattles = global.deathrattles or {}

  global.deliveries = {}
  global.deliveries_table_was_previously_empty = true

  global.logistic_train_stops = nil

  --

  global.train_stops = {}
  global.train_stop_at = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'train-stop'}) do
      speaker.register_train_stop(entity)
    end
  end

  --

  global.entangled = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = 'train-stop', name = 'logistic-train-stop'}) do
      speaker.add_speaker_to_ltn_stop(entity)
    end
  end

end

function speaker.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if entity.type == 'train-stop' then speaker.register_train_stop(entity) end

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
      end
    else
      if mb_entity.name == 'logistic-train-stop-announcer' then
        speakerpole = mb_entity
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

  -- disconnect any/only coppy wires
  speakerpole.disconnect_neighbour()

  -- mark speaker pole for death if the station dissapears
  global.deathrattles[script.register_on_entity_destroyed(entity)] = {speakerpole}

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
  global.deathrattles[script.register_on_entity_destroyed(speakerpole)] = {red_signal, green_signal}

  speakerpole.connect_neighbour({
    target_entity = red_signal,
    wire = defines.wire_type.red,
  })

  speakerpole.connect_neighbour({
    target_entity = green_signal,
    wire = defines.wire_type.green,
  })

  global.entries[entity.unit_number] = {
    speakerpole = speakerpole,
    red_signal = red_signal,
    green_signal = green_signal, 
  }
  
  speaker.announce(entity)
end

-- conveniently gets called when a temporary schedule gets removed,
-- and since we want to remove the 'announcement' when the train arrives,
-- we just have to check which station the train is at when it gets taken off.
function speaker.on_train_schedule_changed(event)
  -- game.print("schedule changed @ " .. event.tick)

  -- filter out this train id during debugging
  -- if event.train.id ~= 1236 then return end

  local already_updated = {}

  -- update all the stations where this train caused red/green signals ^-^
  for _, station in ipairs(trains.entangled_with_stations(event.train)) do
    speaker.announce(station)
    already_updated[station.unit_number] = true
  end

  for _, ltn_stop in ipairs(trains.get_ltn_stops_for_train(event.train)) do
    if not already_updated[ltn_stop.unit_number] then
      speaker.announce(ltn_stop.train_stop)
    end
  end
end

-- update the speakerpole signals
function speaker.announce(entity)
  local entry = global.entries[entity.unit_number]
  if not entry then return end

  local red = {}
  local green = {}

  -- entity.surface.create_entity({
  --   name = "flying-text",
  --   position = entity.position,
  --   text = "announcing:",
  -- })

  for _, train in ipairs(entity.get_train_stop_trains()) do

    for _, ltn_stop in ipairs(trains.get_ltn_stops_for_train(train)) do
      if ltn_stop.train_stop.unit_number == entity.unit_number and trains.is_inbound(train, ltn_stop.train_stop) then
        -- this train stops at this station for:

        for _, wait_condition in ipairs(ltn_stop.wait_conditions) do
          if trains.is_valid_ltn_wait_condition(wait_condition) then

            if wait_condition.type == "item_count" then
              if wait_condition.condition.comparator == "≥" then -- this is a pickup
                local what = "item," .. wait_condition.condition.first_signal.name
                local count = wait_condition.condition.constant

                trains.entangle_with_station(train, entity)
                red[what] = (red[what] or 0) + count
              elseif wait_condition.condition.comparator == "=" and wait_condition.condition.constant == 0 then -- this is a delivery
                local what = "item," .. wait_condition.condition.first_signal.name
                local count = train.get_item_count(wait_condition.condition.first_signal.name)

                trains.entangle_with_station(train, entity)
                green[what] = (green[what] or 0) + count
              end
            end

            if wait_condition.type == "fluid_count" then
              if wait_condition.condition.comparator == "≥" then -- this is a pickup
                local what = "fluid," .. wait_condition.condition.first_signal.name
                local count = wait_condition.condition.constant

                trains.entangle_with_station(train, entity)
                red[what] = (red[what] or 0) + count
              elseif wait_condition.condition.comparator == "=" and wait_condition.condition.constant == 0 then -- this is a delivery
                local what = "fluid," .. wait_condition.condition.first_signal.name
                local count = train.get_fluid_count(wait_condition.condition.first_signal.name)

                trains.entangle_with_station(train, entity)
                green[what] = (green[what] or 0) + count
              end
            end

            -- todo: determine delivery/pickup based on circuit conditions

          end
        end
      end

    end
  end

  -- print(serpent.block({
  --   red = red,
  --   green = green,
  -- }))

  if entry.red_signal.valid then
    entry.red_signal.get_control_behavior().parameters = combinator.parameters_from_shipment(red)
  else
    game.print('red signal no longer valid: ' .. entity.unit_number)
  end

  if entry.green_signal.valid then
    entry.green_signal.get_control_behavior().parameters = combinator.parameters_from_shipment(green)
  else
    game.print('green signal no longer valid: ' .. entity.unit_number)
  end
end

function speaker.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

function speaker.register_train_stop(entity)
  global.train_stops[entity.unit_number] = entity

  local connected_rail_position = entity.position

  -- entity.connected_rail can be nil, hence we calc:
  if entity.direction == defines.direction.north then
    connected_rail_position.x = connected_rail_position.x - 2
  elseif entity.direction == defines.direction.east then
    connected_rail_position.y = connected_rail_position.y - 2
  elseif entity.direction == defines.direction.south then
    connected_rail_position.x = connected_rail_position.x + 2
  elseif entity.direction == defines.direction.west then
    connected_rail_position.y = connected_rail_position.y + 2
  end

  local position = util.positiontostr(connected_rail_position)
  -- game.print('register_train_stop @ ' .. position)
  
  global.train_stop_at[position] = entity
end

function speaker.on_dispatcher_updated(event)
  game.print('on_dispatcher_updated @ ' .. event.tick)
  global.deliveries = event.deliveries

  if global.deliveries_table_was_previously_empty then
    global.deliveries_table_was_previously_empty = false
    -- todo: update all speakerpoles
  end
end

function speaker.on_delivery_created(event)
  game.print('on_delivery_created @ ' .. event.tick)
  global.deliveries[event.train.id] = event
  -- todo: update said speakerpole
end

-- garbage collection
function speaker.every_10_minutes()
  for unit_number, entry in pairs(global.entries or {}) do
    if not entry.speakerpole.valid then
      global.entries[unit_number] = nil
    end
  end
end

return speaker
