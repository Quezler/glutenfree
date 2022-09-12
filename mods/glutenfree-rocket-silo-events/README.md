This mod provides an event for when the rocket silo status changes several times after a launch has been initiated:

```
defines.rocket_silo_status.launch_starting
defines.rocket_silo_status.launch_started
defines.rocket_silo_status.engine_starting
defines.rocket_silo_status.arms_retract
defines.rocket_silo_status.rocket_flying
defines.rocket_silo_status.lights_blinking_close
defines.rocket_silo_status.doors_closing
defines.rocket_silo_status.building_rocket
```

The first time a rocket is launched the mod will look for changes in status every tick, but subsequent launches will use a cache.

You can listen for the events in your own mod via: (placed properly within init and load)
```
local rocket_silo_status = {}
for string, i in pairs(defines.rocket_silo_status) do
  rocket_silo_status[i] = string
end

script.on_event(remote.call("glutenfree-rocket-silo-events", "on_rocket_silo_status_changed"), function()
    local text = rocket_silo_status[event.old_status] ..' -> '.. rocket_silo_status[event.rocket_silo.rocket_silo_status]
    game.print(event.tick .. ': ' .. text)

    event.rocket_silo.surface.create_entity({
      name = "flying-text",
      position = event.rocket_silo.position,
      text = text,
    })
  end
end)
```

Currently this mod does not provide events for when a rocket has enough parts to finish building due to lack of event listeners.
