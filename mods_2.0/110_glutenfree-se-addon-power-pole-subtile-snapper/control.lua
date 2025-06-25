local poles = require("scripts.poles")

--

script.on_init(poles.init)
script.on_configuration_changed(poles.init)

--

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, poles.on_created_entity, {
    {filter = "name", name = "se-addon-power-pole"},
    {filter = "ghost_name", name = "se-addon-power-pole"},
  })
end

--

