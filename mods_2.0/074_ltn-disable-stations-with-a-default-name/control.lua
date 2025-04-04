local Handler = require("scripts.handler")

--

local events = {
  [defines.events.on_entity_renamed] = Handler.on_entity_renamed,
  [defines.events.on_entity_settings_pasted] = Handler.on_entity_renamed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_entity_renamed, {
    {filter = "name", name = "logistic-train-stop"},
  })
end

local function init()
  Handler.init()
end

script.on_init(function()
  init()
end)

script.on_configuration_changed(function(event)
  init()
end)
