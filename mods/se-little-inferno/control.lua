local handler = require("scripts.handler")

script.on_init(handler.on_init)
script.on_configuration_changed(handler.on_configuration_changed)
script.on_load(handler.on_load)

script.on_event(defines.events.on_surface_created, handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, handler.on_surface_deleted)

script.on_event(defines.events.on_chunk_charted, handler.on_chunk_charted)
script.on_event(defines.events.on_chunk_deleted, handler.on_chunk_deleted)

script.on_event(defines.events.on_entity_cloned, handler.on_entity_cloned, {
  {filter = 'name', name = 'se-little-inferno'},
})
script.on_event(defines.events.script_raised_destroy, handler.script_raised_destroy, {
  {filter = 'name', name = 'se-little-inferno'},
})

-- /c game.print(remote.call("se-little-inferno", "get_enabled_for_surface_index", {surface_index = game.player.surface.index}))
-- /c remote.call("se-little-inferno", "set_enabled_for_surface_index", {surface_index = game.player.surface.index, enabled = true})
-- /c remote.call("se-little-inferno", "set_enabled_for_surface_index", {surface_index = game.player.surface.index, enabled = false})

remote.add_interface("se-little-inferno", {
  get_enabled_for_surface_index = handler.get_enabled_for_surface_index,
  set_enabled_for_surface_index = handler.set_enabled_for_surface_index,
})

script.on_event(defines.events.on_gui_click, handler.on_gui_click)
script.on_event(defines.events.on_trigger_created_entity, handler.on_trigger_created_entity)
