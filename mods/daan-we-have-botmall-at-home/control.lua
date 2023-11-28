local Handler = require('scripts.handler')

--

script.on_init(Handler.on_init)

local events = {
  [defines.events.on_surface_created] = Handler.on_surface_created,
  [defines.events.on_surface_deleted] = Handler.on_surface_deleted,

  [defines.events.on_player_selected_area] = Handler.on_player_selected_area,
  [defines.events.on_player_reverse_selected_area] = Handler.on_player_reverse_selected_area,

  [defines.events.on_gui_closed] = Handler.on_recipe_changed,
  [defines.events.on_entity_settings_pasted] = Handler.on_recipe_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
