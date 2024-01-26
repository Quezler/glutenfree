local poles = require('scripts.poles')

--

local function init()
  global = {}

  poles.init()
end

script.on_init(init)
script.on_configuration_changed(init)

--

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, poleson_created_entity, {
    {filter = 'name', name = 'se-addon-power-pole'},
  })
end

--

