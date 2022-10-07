script.on_event(defines.events.on_train_schedule_changed, function(event)
  game.print(serpent.block( event.train.schedule ))



  if event.train.schedule then

    local modified_schedule = false
    local schedule = event.train.schedule
    for i, record in ipairs(schedule.records) do
      if record.wait_conditions then
        for j, wait_condition in ipairs(record.wait_conditions) do
          if wait_condition.type == 'circuit' and wait_condition.condition then
            if wait_condition.condition.first_signal.name == 'full-cargo-inventory' then

              if wait_condition.condition.comparator ~= '=' then
                wait_condition.condition.comparator = '='
                modified_schedule = true
              end

              if wait_condition.condition.constant ~= 1 then
                wait_condition.condition.constant = 1
                modified_schedule = true
              end

            end
          end
        end
      end
    end

    if modified_schedule then
      event.train.schedule = schedule
    end

  end
end)
