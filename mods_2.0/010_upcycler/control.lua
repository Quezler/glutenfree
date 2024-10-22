local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  entity.custom_status = {
    diode = defines.entity_status_diode.green,
    label = {"upcycler.status"},
  }

  local inserted = entity.get_inventory(defines.inventory.furnace_source).insert({name = "upcycle-any-quality", count = 1})
  assert(inserted > 0)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "upcycler"},
  })
end
