local silo = {}

function silo.init()
  global.cargo_silo_entries = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = "container", name = "se-rocket-launch-pad" })) do
      silo.register(entity)
    end
  end

end

function silo.is_valid_cargo_rocket_silo(entity)
  if not entity then return false end
  if not entity.valid then return false end
  if entity.type ~= "container" then return false end
  if entity.name ~= "se-rocket-launch-pad" then return false end

  return true
end

function silo.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if not silo.is_valid_cargo_rocket_silo(entity) then return end

  -- game.print(entity.name)
  silo.register(entity)
end

function silo.register(entity)
  global.cargo_silo_entries[entity.unit_number] = {
    container = entity,
    combinator = nil,
  }

  -- print("registered silo ["..entity.unit_number.."].")
end

function silo.random_tick(entry)
  if not entry.combinator or not entry.combinator.valid then
    entry.combinator = entry.container.surface.find_entity("se-rocket-launch-pad-combinator", entry.container.position)

    local fueltank_signal = entry.combinator.get_or_create_control_behavior().get_signal(1)
    local sections_signal = entry.combinator.get_or_create_control_behavior().get_signal(2)
    local capsules_signal = entry.combinator.get_or_create_control_behavior().get_signal(3)

    if (fueltank_signal.signal.name ~= "se-liquid-rocket-fuel"  ) then error("did not expect the ["..fueltank_signal.signal.name.."] signal at combinator position 1.") end
    if (sections_signal.signal.name ~= "se-cargo-rocket-section") then error("did not expect the ["..sections_signal.signal.name.."] signal at combinator position 2.") end
    if (capsules_signal.signal.name ~= "se-space-capsule")        then error("did not expect the ["..capsules_signal.signal.name.."] signal at combinator position 3.") end
  end

  --

  local has_any_rocket_fuel = entry.combinator.get_or_create_control_behavior().get_signal(1).count > 0
  if not has_any_rocket_fuel then return end

  local missing_sections = 100 - entry.combinator.get_or_create_control_behavior().get_signal(2).count -- todo: - any sections still in the container
  local missing_capsules = 1   - entry.combinator.get_or_create_control_behavior().get_signal(3).count -- todo: - any capsules still in the container

  if missing_sections > 0 or missing_capsules > 0 then

    local proxy = entry.container.surface.find_entity("item-request-proxy", entry.container.position)
    if not proxy then
      local to_create = {
        name = "item-request-proxy",
        position = entry.container.position,
        target = entry.container,
        force =  entry.container.force,
        modules = {}
      }

      if (missing_sections > 0) then to_create.modules["se-cargo-rocket-section"] = missing_sections end
      if (missing_capsules > 0) then to_create.modules["se-space-capsule"       ] = missing_capsules end

      print(serpent.block(to_create.modules))

      entry.container.surface.create_entity(to_create)
    end
  end
end

function silo.every_10_seconds()
  for unit_number, entry in pairs(global.cargo_silo_entries) do

    if entry.container and entry.container.valid then
      silo.random_tick(entry)
    else
      global.cargo_silo_entries[unit_number] = nil
    end

  end
end

return silo
