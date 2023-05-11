local handler = require("scripts.handler")

script.on_init(handler.on_init)

script.on_event(defines.events.on_surface_created, handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, handler.on_surface_deleted)

script.on_event(defines.events.on_chunk_charted, handler.on_chunk_charted)
script.on_event(defines.events.on_chunk_deleted, handler.on_chunk_deleted)
