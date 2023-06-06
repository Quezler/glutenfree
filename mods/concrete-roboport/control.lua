local ConcreteRoboport = require('scripts.concrete-roboport')

--

script.on_init(ConcreteRoboport.on_init)

local events = {
  [defines.events.on_built_entity]       = ConcreteRoboport.on_created_entity,
  [defines.events.on_robot_built_entity] = ConcreteRoboport.on_created_entity,
  [defines.events.script_raised_built]   = ConcreteRoboport.on_created_entity,
  [defines.events.script_raised_revive]  = ConcreteRoboport.on_created_entity,
  [defines.events.on_entity_cloned]      = ConcreteRoboport.on_created_entity,

  [defines.events.on_selected_entity_changed] = ConcreteRoboport.on_selected_entity_changed,

  [defines.events.on_surface_created] = ConcreteRoboport.on_surface_created,
  [defines.events.on_surface_deleted] = ConcreteRoboport.on_surface_deleted,

  [defines.events.on_player_built_tile]    = ConcreteRoboport.on_built_tile,
  [defines.events.on_robot_built_tile]     = ConcreteRoboport.on_built_tile,
  -- [defines.events.script_raised_set_tiles] = ConcreteRoboport.on_built_tile,

  [defines.events.on_entity_destroyed] = ConcreteRoboport.on_entity_destroyed,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
