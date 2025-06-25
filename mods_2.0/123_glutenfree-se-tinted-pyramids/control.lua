local Handler = require("scripts.handler")

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
-- script.on_event(defines.events.on_tick, Handler.on_tick)

-- low ups ways of detecting when the module might have been looted, inserters can bypass this
script.on_event(defines.events.on_player_fast_transferred, Handler.on_player_fast_transferred)
script.on_event(defines.events.on_gui_closed, Handler.on_gui_closed)

-- to detect when the universe explorer gui gets opened or altered
script.on_event(defines.events.on_gui_opened, Handler.on_gui_opened)
script.on_event(defines.events.on_gui_click, Handler.on_gui_click)
