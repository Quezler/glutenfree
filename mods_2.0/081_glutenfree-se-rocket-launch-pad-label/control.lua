local handler = require("scripts.launchpad")

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

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, handler.on_created_entity, {
    {filter = "name", name = "se-rocket-launch-pad"},
  })
end

local events = {
  [defines.events.on_gui_opened] = handler.on_gui_opened,
  [defines.events.on_gui_selection_state_changed] = handler.on_gui_selection_state_changed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
