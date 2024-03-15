local mod_prefix = 'fff-402-radars-'

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface

  local circuit_connector = surface.find_entity(mod_prefix .. 'circuit-connector', entity.position)
  if circuit_connector == nil then
    circuit_connector = surface.create_entity{
      name = mod_prefix .. 'circuit-connector',
      force = entity.force,
      position = entity.position,
    }

    circuit_connector.destructible = false
  end

  local registration_number = script.register_on_entity_destroyed(entity)

  global.surfacedata[surface.index].structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,

    circuit_connector = circuit_connector,
  }

  global.deathrattles[registration_number] = {circuit_connector}
  global.owned_by_deathrattle[circuit_connector.unit_number] = registration_number
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'type', type = 'radar'},
  })
end

local function on_surface_created(event)
  assert(global.surfacedata[event.surface_index] == nil)
  global.surfacedata[event.surface_index] = {
    structs = {},
  }
end

local function on_surface_deleted(event)
  assert(global.surfacedata[event.surface_index] ~= nil)
  global.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, on_surface_created)
script.on_event(defines.events.on_surface_deleted, on_surface_deleted)

local function on_dolly_moved_entity(event)
  local struct = global.surfacedata[event.moved_entity.surface.index].structs[event.moved_entity.unit_number]
  if struct == nil then return end

  struct.circuit_connector.teleport(event.moved_entity.position)
end

local function register_events()
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_dolly_moved_entity)
  end

  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
    remote.call("PickerDollies", "add_blacklist_name", mod_prefix .. 'circuit-connector')
  end
end

local function on_init(event)
  global.surfacedata = {}
  global.deathrattles = {}
  global.owned_by_deathrattle = {}

  for _, surface in pairs(game.surfaces) do
    on_surface_created({surface_index = surface.index})
    for _, entity in pairs(surface.find_entities_filtered{type = 'radar'}) do
      on_created_entity({entity = entity})
    end
  end

  register_events()
end

script.on_init(on_init)
script.on_load(register_events)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, entity in ipairs(deathrattle) do
      if global.owned_by_deathrattle[entity.unit_number] == event.registration_number then
        entity.destroy()
      end
    end
  end
end)
