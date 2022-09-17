local buffer = require('scripts.buffer')

--

local function init()
  --
end

local function load()
  --
end

script.on_init(function()
  init()
  load()
end)

script.on_load(function()
  load()
end)

script.on_configuration_changed(function(event)
  init()
end)

--

local events = {
  [defines.events.on_gui_closed] = buffer.on_gui_closed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
