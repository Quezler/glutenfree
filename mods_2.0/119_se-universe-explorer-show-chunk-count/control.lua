local Handler = require('scripts.handler')

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

script.on_configuration_changed(Handler.on_configuration_changed)
script.on_event(defines.events.on_chunk_generated, Handler.on_chunk_generated)
script.on_event(defines.events.on_chunk_deleted, Handler.on_chunk_deleted)
