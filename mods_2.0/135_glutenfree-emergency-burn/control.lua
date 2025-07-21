local handler = require("scripts.capsule")

local events = {
  [defines.events.on_gui_opened] = handler.on_gui_opened,
  [defines.events.on_gui_selection_state_changed] = handler.on_gui_selection_state_changed,

  [defines.events.on_player_driving_changed_state] = handler.on_player_driving_changed_state,

  [defines.events.on_object_destroyed] = handler.on_object_destroyed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

--

script.on_init(handler.on_init)
script.on_load(handler.on_load)

script.on_event(defines.events.script_raised_built, handler.script_raised_built, {
  {filter = "name", name = "se-space-capsule-scorched-_-vehicle"},
})
