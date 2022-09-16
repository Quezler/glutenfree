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

  -- -- if the current destination is not a temporary one, bail out
  -- if not you_are_on_your_way_to.temporary then return false end

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

return train
