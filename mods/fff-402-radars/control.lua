local mod_prefix = 'fff-402-radars-'

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface

  local red_wire_chest = surface.find_entity(mod_prefix .. 'circuit-connector', entity.position)
  if red_wire_chest == nil then
    red_wire_chest = surface.create_entity{
      name = mod_prefix .. 'circuit-connector',
      force = entity.force,
      position = entity.position,
    }

    red_wire_chest.destructible = false
  end

  global.surfacedata[surface.index].structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
  }

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {red_wire_chest}
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

local function on_init(event)
  global.surfacedata = {}
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    on_surface_created({surface_index = surface.index})
    for _, entity in pairs(surface.find_entities_filtered{type = 'radar'}) do
      on_created_entity({entity = entity})
    end
  end
end

script.on_init(on_init)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, entity in ipairs(deathrattle) do
      entity.destroy()
    end
  end
end)
