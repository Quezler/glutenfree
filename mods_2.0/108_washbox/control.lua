require("shared")

local mod = {}

script.on_init(function()
  storage.deathrattles = {}
  storage.structs = {}
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local pipe = entity.surface.create_entity{
    name = mod_prefix .. "pipe",
    position = entity.position,
    force = entity.force,
  }
  pipe.destructible = false

  entity.fluidbox.add_linked_connection(1, pipe, 1)
  entity.fluidbox.add_linked_connection(2, pipe, 2)

  local beacon = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }
  beacon.destructible = false

  remote.call("beacon-interface", "set_effects", beacon.unit_number, {
    speed = -50,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0,
  })

  local beacon_overload = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface-overload",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }

  beacon_overload.destructible = false
  remote.call("beacon-interface", "set_effects", beacon_overload.unit_number, {
    speed = -10000,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0,
  })

  storage.structs[entity.unit_number] = {
    entity = entity,
    pipe = pipe,
    beacon = beacon,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = true
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "washbox"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[event.useful_id]
    if struct then storage.structs[event.useful_id] = nil
      if struct.pipe then struct.pipe.destroy() end
      if struct.beacon then struct.beacon.destroy() end
      if struct.beacon_overload then struct.beacon_overload.destroy() end
    end
  end
end)
