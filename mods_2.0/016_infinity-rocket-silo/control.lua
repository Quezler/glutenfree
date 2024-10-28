local Handler = {}

script.on_init(function()
  local items = remote.call("freeplay", "get_created_items")
  items["infinity-rocket-silo"] = 1
  -- items["space-platform-starter-pack"] = 1
  remote.call("freeplay", "set_created_items", items)

  local platform = game.forces["player"].create_space_platform{
    name = "platform",
    planet = "nauvis",
    starter_pack = "space-platform-starter-pack",
  }
  assert(platform)
  platform.apply_starter_pack()

  storage.structs = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local pole = entity.surface.create_entity{
    name = "small-electric-pole",
    force = entity.force,
    position = {entity.position.x + 2, entity.position.y + 5},
  }

  entity.get_or_create_control_behavior().read_mode = defines.control_behavior.rocket_silo.read_mode.orbital_requests

  local silo_connector = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local pole_connector = pole.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  -- assert(silo_connector)
  -- assert(pole_connector)
  -- game.print(serpent.line(silo_connector))
  -- game.print(serpent.line(pole_connector))
  assert(silo_connector.connect_to(pole_connector))

  storage.structs[entity.unit_number] = {
    silo = entity,
    pole = pole,

    inventory = entity.get_inventory(defines.inventory.rocket_silo_rocket),
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  -- defines.events.on_robot_built_entity,
  -- defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "infinity-rocket-silo"},
  })
end

local prioritized_items = {
  ["space-platform-foundation"] = true,
  ["cargo-bay"] = true,
}

function Handler.pick_signal_and_count(signals)
  assert(signals)

  for _, signal_and_count in ipairs(signals) do
    if signal_and_count.count > 0 then
      return signal_and_count
    end
  end
end

function Handler.on_tick(event)
  for unit_number, struct in pairs(storage.structs) do
    if struct.silo.valid == false then
      storage.structs[unit_number] = nil
      goto continue
    end

    local network = struct.silo.get_circuit_network(defines.wire_connector_id.circuit_red)
    local signal_and_count = Handler.pick_signal_and_count(network.signals or {})
    if signal_and_count then
      log(serpent.line(signal_and_count))

      struct.inventory.clear()
      struct.inventory.insert({name = signal_and_count.signal.name, quality = signal_and_count.signal.quality, count = 1000000})
    end

    ::continue::
  end
end

script.on_event(defines.events.on_tick, Handler.on_tick)

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  assert(event.rocket_silo)
  if event.rocket_silo.name ~= "infinity-rocket-silo" then return end

  local inventory = event.rocket.cargo_pod.get_inventory(defines.inventory.cargo_unit)
  assert(inventory)

  for slot = 1, #inventory do
    local stack = inventory[slot]
    if stack.valid_for_read and prioritized_items[stack.name] then
      event.rocket.cargo_pod.force_finish_ascending()
      -- event.rocket.cargo_pod.force_finish_descending()
      return
    end
  end
end)
