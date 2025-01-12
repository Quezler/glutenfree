local Handler = {}

script.on_init(function()
  storage.surface = game.planets["greedy-inserter"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.greedy_inserters = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  storage.greedy_inserters[entity.unit_number] = {
    entity = entity,
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
    {filter = "name", name = "greedy-inserter"},
  })
end
