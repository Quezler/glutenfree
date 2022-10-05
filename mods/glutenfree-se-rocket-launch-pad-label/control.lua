local handler = require('scripts.launchpad')

--

local function init()
  handler.init()
end

local function load()
  --
end

script.on_init(function()
  init()
end)

script.on_load(function()
  load()
end)

script.on_configuration_changed(handler.on_configuration_changed)

--

local events = {
  [defines.events.on_gui_opened] = handler.on_gui_opened,
  [defines.events.on_gui_selection_state_changed] = handler.on_gui_selection_state_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
