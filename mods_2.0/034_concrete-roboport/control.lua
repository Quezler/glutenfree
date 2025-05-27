require("shared")

function table_first(table)
  for key, value in pairs(table) do
    return value
  end
end

local ConcreteRoboport = require("scripts.concrete-roboport")

--

script.on_init(ConcreteRoboport.on_init)
script.on_configuration_changed(ConcreteRoboport.on_configuration_changed)

local events = {
  [defines.events.on_selected_entity_changed] = ConcreteRoboport.on_selected_entity_changed,

  [defines.events.on_player_built_tile]         = ConcreteRoboport.on_built_tile,
  [defines.events.on_robot_built_tile]          = ConcreteRoboport.on_built_tile,
  [defines.events.on_space_platform_built_tile] = ConcreteRoboport.on_built_tile,

  [defines.events.script_raised_set_tiles]      = ConcreteRoboport.on_built_tile,

  [defines.events.on_player_mined_tile]         = ConcreteRoboport.on_built_tile,
  [defines.events.on_robot_mined_tile]          = ConcreteRoboport.on_built_tile,
  [defines.events.on_space_platform_mined_tile] = ConcreteRoboport.on_built_tile,

  [defines.events.on_object_destroyed] = ConcreteRoboport.on_object_destroyed,
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
  script.on_event(event, ConcreteRoboport.on_created_entity, {
    {filter = "name", name = "concrete-roboport"},
  })
end
