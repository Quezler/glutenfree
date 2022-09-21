--

function on_train_schedule_changed(event)
  local schedule = event.train.schedule
  if not schedule then return end
  local schedule_modified = false

  for record_i, record in ipairs(schedule.records or {}) do
    local delivers_fluid = false

    for wait_condition_i, wait_condition in pairs(record.wait_conditions or {}) do

      if wait_condition.type == "fluid_count"
      and wait_condition.condition
      and wait_condition.condition.comparator == "="
      and wait_condition.condition.constant == 0
      then
        delivers_fluid = true
      end

      if delivers_fluid
      and wait_condition.condition
      and wait_condition.compare_type == "or"
      and wait_condition.ticks == settings.global['ltn-dispatcher-stop-timeout(s)'].value * 60
      and wait_condition.type == "time"
      then
        schedule.records[record_i].wait_conditions[wait_condition_i] = nil
        schedule_modified = true
      end

    end
  end
  
  if schedule_modified then
    event.train.schedule = schedule
  end
end

--

local events = {
  [defines.events.on_train_schedule_changed] = on_train_schedule_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
