local Handler = require('scripts.handler')

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)

script.on_event(defines.events.on_gui_opened, Handler.on_gui_opened)

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)
