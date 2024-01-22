how to listen:
```
local function register_events(event)
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), function(event)
    log(serpent.block(event))
  end)
end

script.on_init(register_events)
script.on_load(register_events)
```

what you get:
```
{
  surface_index = 1,
  zone_index = 523,

  new_amount_for_one = 478148.66421992512,
  new_amount = 2138345.833092948,
  efficiency = 0.22360679774997898,
}
```
