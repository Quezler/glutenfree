local Handler = {}

function Handler.on_init()
  storage.requester_chests = {}
  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "logistic-container"})) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local logistic_point = entity.get_logistic_point(defines.logistic_member_index.logistic_container)
  if logistic_point.mode ~= defines.logistic_mode.requester then return end

  storage.requester_chests[entity.unit_number] = {
    requester = entity,
    assembler = nil,
  }

  Handler.check_requester(entity)
end

function Handler.check_requester(entity)
  local struct = storage.requester_chests[entity.unit_number]
  assert(struct)

  if entity.request_from_buffers then
    if struct.assembler == nil then
      struct.assembler = entity.surface.create_entity{
        name = "request-from-buffer-chests",
        force = entity.force,
        position = entity.position,
      }
      assert(struct.assembler)
      struct.assembler.destructible = false
      storage.deathrattles[script.register_on_object_destroyed(entity)] = struct.assembler
    end
  else
    if struct.assembler ~= nil then
      struct.assembler.destroy()
      struct.assembler = nil
    end
  end
end

--

script.on_init(Handler.on_init)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity, -- typically not placable in space, but still
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "type", type = "logistic-container"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattle.destroy()
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.unit_number and storage.requester_chests[event.destination.unit_number] then
    Handler.check_requester(event.destination)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.entity and event.entity.unit_number and storage.requester_chests[event.entity.unit_number] then
    Handler.check_requester(event.entity)
  end
end)
