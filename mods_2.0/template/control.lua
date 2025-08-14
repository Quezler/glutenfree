local mod = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  --
end)

function new_struct(table, struct)
  assert(struct.id)
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

mod.on_created_entity_filters = {
  {filter = "name", name = "entity-name"},
}

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct.id}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      --
    end
  end
end)
