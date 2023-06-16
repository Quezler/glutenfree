function remove_invalid_entities_from(entities)
  for unit_number, entity in pairs(entities) do
    if not entity.valid then
      entities[unit_number] = nil
    end
  end
end

function set_logistic_network(entity, logistic_network)
  if logistic_network then
    entity.logistic_network = logistic_network
  else -- cannot set logistic_network to nil directly
    local null = entity.surface.create_entity{
      name = "roboport",
      force = entity.force,
      position = entity.position,
    }
    entity.logistic_network = null.logistic_network
    null.destroy()
  end
end

--

local Handler = require('scripts.handler')

--

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

local events = {
  [defines.events.on_surface_created] = Handler.on_surface_created,
  [defines.events.on_surface_deleted] = Handler.on_surface_deleted,

  [defines.events.on_gui_closed] = Handler.on_gui_closed,
  [defines.events.on_entity_settings_pasted] = Handler.on_entity_settings_pasted,

  [defines.events.on_built_entity]       = Handler.on_created_entity,
  [defines.events.on_robot_built_entity] = Handler.on_created_entity,
  [defines.events.script_raised_built]   = Handler.on_created_entity,
  [defines.events.script_raised_revive]  = Handler.on_created_entity,
  [defines.events.on_entity_cloned]      = Handler.on_created_entity,

  [defines.events.on_robot_pre_mined] = Handler.on_robot_pre_mined,
  [defines.events.on_tick] = Handler.on_tick,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end
