local util = require('util')

local train = {}

function train.is_waiting_at_depo(entity)
  -- wait_conditions = {
  --   {
  --     compare_type = "and",
  --     ticks = 300,
  --     type = "inactivity"
  --   }
  -- }
end

function train.is_inbound(train, station)
  -- no schedule, so definately not inbound
  if not train.schedule then return false end

  -- require more than 2 stops (depot + temp + station)
  if #train.schedule.records < 3 then return false end

  -- local you_are_on_your_way_to = train.schedule.records[train.schedule.current] -- brazil

  -- is there still a (temporary) stop between the train and this station?
  for i = train.schedule.current + 1, #train.schedule.records do
    if train.schedule.records[i].station then
      -- game.print('a ' .. train.schedule.records[i].station)
      -- game.print('b ' .. station.backer_name)
      if train.schedule.records[i].station == station.backer_name then
        return true
      end
    end
  end

  -- current at this station, or already went past it
  return false
end

function train.get_ltn_stops_for_train(train)
  local stops = {}

  if not train.schedule then return stops end

  for i, record in ipairs(train.schedule.records) do
    if record.temporary then

      local position = util.positiontostr(record.rail.position)
      -- game.print("temporary @ " .. position)

      local station = global.train_stop_at[position]
      if station and station.valid then
        -- is this temporary station at the same rail as the next stop?
        local next_stop = train.schedule.records[i + 1]
        if next_stop and next_stop.station == station.backer_name then
          table.insert(stops, {
            train_stop = station,
            wait_conditions = next_stop.wait_conditions
          })
        end
      end

    end
  end

  return stops
end

function train.is_valid_ltn_wait_condition(wait_condition)

  -- has no valid circuit condition
  if not wait_condition.condition then return false end

  -- the signal is improperly set
  if not wait_condition.condition.first_signal or not wait_condition.condition.first_signal.name then return false end

  -- is not being compared to a number
  if wait_condition.condition.constant == nil then return false end

  return true
end

-- flag a train with one or more stations
function train.entangle_with_station(train, station)
  if not global.entangled[train.id] then global.entangled[train.id] = {} end

  global.entangled[train.id][station.unit_number] = station
end

-- retrieve all the stations this train was flagged with
function train.entangled_with_stations(train)
  local stations = {}

  if global.entangled then
    for unit_number, station in pairs(global.entangled[train.id] or {}) do
      if station.valid then
        table.insert(stations, station)
      end
    end
  end

  -- we observed it, didn't we? :)
  global.entangled[train.id] = nil

  return stations
end

return train
