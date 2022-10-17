local Handler = require('scripts.handler')

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_tick, Handler.on_tick)

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  game.print(event.tick)
end)
