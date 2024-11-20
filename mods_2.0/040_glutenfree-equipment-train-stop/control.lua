local Handler = require("scripts.handler")

--

local function init()
  Handler.init()
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
  Handler.on_configuration_changed()
end)

--

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "glutenfree-equipment-train-stop-station"},
  })
end

local events = {
  [defines.events.on_object_destroyed] = Handler.on_object_destroyed,
  [defines.events.on_tick] = Handler.on_tick, -- todo: only have this handler active while global.tripwires_to_replace is not empty
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
