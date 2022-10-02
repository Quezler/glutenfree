local kr_air_purifier = require("scripts.kr-air-purifier")

--

local function init()
  global = {}

  kr_air_purifier.init()
end

script.on_init(function()
  init()
end)

script.on_configuration_changed(function(event)
  init()
end)

--

script.on_event(defines.events.on_built_entity, function(event)
  kr_air_purifier.on_created_entity(event)
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  kr_air_purifier.on_created_entity(event)
end)

script.on_event(defines.events.script_raised_built, function(event)
  kr_air_purifier.on_created_entity(event)
end)

script.on_event(defines.events.script_raised_revive, function(event)
  kr_air_purifier.on_created_entity(event)
end)

script.on_event(defines.events.on_entity_cloned, function(event)
  kr_air_purifier.on_created_entity(event)
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  kr_air_purifier.on_entity_destroyed(event)
end)

--

script.on_nth_tick(60 * 60 * 5, function()
  kr_air_purifier.every_five_minutes()
end)
