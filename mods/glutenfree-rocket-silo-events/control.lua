local handler = {}

local function init()

  -- holds timings for each silo:rocket name combination
  global.timings = {}

  if not 'debug' then
    -- base
    global.timings['rocket-silo:rocket-silo-rocket'] = {
      [1]    = 14, -- defines.rocket_silo_status.launch_started
      [121]  =  9, -- defines.rocket_silo_status.engine_starting
      [451]  = 10, -- defines.rocket_silo_status.arms_retract
      [555]  = 11, -- defines.rocket_silo_status.rocket_flying
      [1095] = 12, -- defines.rocket_silo_status.lights_blinking_close
      [1276] = 13, -- defines.rocket_silo_status.doors_closing
      [1532] =  0, -- defines.rocket_silo_status.building_rocket
    }

    -- space exploration
    global.timings['se-rocket-launch-pad-silo:se-cargo-rocket'] = {
      [1]    = 14, -- defines.rocket_silo_status.launch_started
      [121]  =  9, -- defines.rocket_silo_status.engine_starting
      [451]  = 10, -- defines.rocket_silo_status.arms_retract
      [555]  = 11, -- defines.rocket_silo_status.rocket_flying
      [1095] = 12, -- defines.rocket_silo_status.lights_blinking_close
      [1276] = 13, -- defines.rocket_silo_status.doors_closing
      [1532] =  0, -- defines.rocket_silo_status.building_rocket
    }
  end

  -- when the silo:rocket timing is missing, measure and cache it, this holds all in-progress measurements
  global.active_measurements = {}
  script.on_event(defines.events.on_tick, nil)

  -- events to be raised at certain ticks for rocket silos that are currently cycling through cached timings
  global.to_raise_at = global.to_raise_at or {}
end

script.on_init(init)
script.on_configuration_changed(init)

local function load()
  -- load pending on_tick's
  if table_size(global.active_measurements) > 0 then
    script.on_event(defines.events.on_tick, handler.on_tick)
  end

  -- load pending on_nth_tick's
  for tick, _ in pairs(global.to_raise_at) do
    script.on_nth_tick(tick, handler.on_nth_tick)
  end
end

script.on_load(load)

--

local rocket_silo_status = {}
for string, i in pairs(defines.rocket_silo_status) do
  rocket_silo_status[i] = string
end

--

local on_rocket_silo_status_changed = script.generate_event_name()
remote.add_interface("glutenfree-rocket-silo-events", {
  on_rocket_silo_status_changed = function() return on_rocket_silo_status_changed end
})

function handler.on_rocket_launch_ordered(event)
  local cache_key = event.rocket_silo.name .. ':' .. event.rocket.name

  -- the state changed from `rocket_ready` to `launch_starting` the moment the launch was ordered, raise this event to reflect that:
  script.raise_event(on_rocket_silo_status_changed, {
    old_status = defines.rocket_silo_status.rocket_ready,
    rocket_silo = event.rocket_silo,
  })

  -- use cached timing if this silo + rocket combo has launched before
  if global.timings[cache_key] then

    -- game.print(cache_key)
    -- game.print(serpent.block(global.timings[cache_key]))
    -- print(cache_key)
    -- print(serpent.block(global.timings[cache_key]))

    local old_status = defines.rocket_silo_status.launch_starting
    for ticks, status in pairs(global.timings[cache_key]) do

      -- tick to raise said event at
      local tick = game.tick + ticks

      if not global.to_raise_at[tick] then
        global.to_raise_at[tick] = {{old_status = old_status, rocket_silo = event.rocket_silo}}
        script.on_nth_tick(tick, handler.on_nth_tick)
      else
        table.insert(global.to_raise_at[tick], {old_status = old_status, rocket_silo = event.rocket_silo})
      end

      old_status = status
    end
  else -- comment out this else (just this line) in order to compare/confirm both the stored timing & measurement match
    global.active_measurements[event.rocket_silo.unit_number] = {
      old_status = event.rocket_silo.rocket_silo_status, -- defines.rocket_silo_status.launch_started
      rocket_silo = event.rocket_silo,
      cache_key = cache_key,
      tick = 0,

      timings = {},
    }

    -- if the table size is now 1, register the on_tick
    if table_size(global.active_measurements) == 1 then
      script.on_event(defines.events.on_tick, handler.on_tick)
    end
  end
end

function handler.on_tick(event)
  for unit_number, active_measurement in pairs(global.active_measurements) do
    active_measurement.tick = active_measurement.tick + 1
    print('rocket silo #' .. unit_number .. ': '.. active_measurement.tick .. ' ' .. active_measurement.rocket_silo.rocket_silo_status .. ' = ' .. rocket_silo_status[active_measurement.rocket_silo.rocket_silo_status])
    
    -- if the status has changed since the last tick, raise an event & process the measurement
    if active_measurement.old_status ~= active_measurement.rocket_silo.rocket_silo_status then
      script.raise_event(on_rocket_silo_status_changed, {
        old_status = active_measurement.old_status,
        rocket_silo = active_measurement.rocket_silo,
      })

      -- store the ticks since ordered when this status first appeared
      active_measurement.timings[active_measurement.tick] = active_measurement.rocket_silo.rocket_silo_status

      -- now flag the current status as the old status
      active_measurement.old_status = active_measurement.rocket_silo.rocket_silo_status

      -- the silo doors have finished closing, remove the event listener to save some ups
      if active_measurement.old_status == defines.rocket_silo_status.building_rocket then
        global.timings[active_measurement.cache_key] = active_measurement.timings

        global.active_measurements[unit_number] = nil
        if table_size(global.active_measurements) == 0 then
          script.on_event(defines.events.on_tick, nil)
        end
      end
    end
    
  end
end

function handler.on_nth_tick(event)
  if not global.to_raise_at[event.tick] then return end -- hmm?

  -- raise an event for each rocket that changes status this tick
  for _, to_raise in ipairs(global.to_raise_at[event.tick]) do
    script.raise_event(on_rocket_silo_status_changed, to_raise)
  end

  -- ensure modulus does not re-trigger
  global.to_raise_at[event.tick] = nil
  script.on_nth_tick(event.tick, nil)
end

script.on_event(defines.events.on_rocket_launch_ordered, handler.on_rocket_launch_ordered)
