local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local filter = entity.fluidbox.get_filter(2)
  assert(filter)
  assert(filter.name == "pump-with-adjustable-flow-rate")

  entity.fluidbox[2] = {
    name = "pump-with-adjustable-flow-rate",
    amount = 100,
    temperature = 600,
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "pump-with-adjustable-flow-rate"},
  })
end
