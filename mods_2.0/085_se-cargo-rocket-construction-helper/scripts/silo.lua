local silo = {}

function silo.init()
  storage.cargo_silo_entries = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = "container", name = "se-rocket-launch-pad" })) do
      silo.register(entity)
    end
  end

end

function silo.on_created_entity(event)
  local entity = event.entity or event.destination

  silo.register(entity)
end

function silo.register(entity)
  storage.cargo_silo_entries[entity.unit_number] = {
    container = entity,
    combinator = nil,
    silo = nil,
  }

  -- print("registered silo ["..entity.unit_number.."].")
end

local delivery_allowed = {
  [defines.rocket_silo_status.lights_blinking_close] = true,
  [defines.rocket_silo_status.doors_closing] = true,
  [defines.rocket_silo_status.building_rocket] = true,
}

function silo.random_tick(entry)

  if not entry.silo or not entry.silo.valid then
    entry.silo = entry.container.surface.find_entity("se-rocket-launch-pad-silo", entry.container.position)
  end

  -- stop here if there is a finished rocked in/on/above the silo
  if not delivery_allowed[entry.silo.rocket_silo_status] then return end

  if not entry.combinator or not entry.combinator.valid then
    entry.combinator = entry.container.surface.find_entity("se-rocket-launch-pad-combinator", entry.container.position)
    if not entry.combinator then return end -- called in the same tick the silo was constructed, and SE needing one more?

    local section = entry.combinator.get_logistic_sections().get_section(1)
    local sections_filter = section.get_slot(2)
    local capsules_filter = section.get_slot(3)

    if (sections_filter.value.name ~= "se-cargo-rocket-section") then error("did not expect the ["..sections_filter.value.name.."] signal at combinator position 2.") end
    if (capsules_filter.value.name ~= "se-space-capsule")        then error("did not expect the ["..capsules_filter.value.name.."] signal at combinator position 3.") end
  end

  --

  local container_inventory = entry.container.get_inventory(defines.inventory.chest)

  local section = entry.combinator.get_logistic_sections().get_section(1)
  local missing_sections = 100 - section.get_slot(2).min - container_inventory.get_item_count("se-cargo-rocket-section")
  local missing_capsules = 1   - section.get_slot(3).min - container_inventory.get_item_count("se-space-capsule")

  if missing_sections > 0 or missing_capsules > 0 then

    local proxy = entry.container.surface.find_entity("item-request-proxy", entry.container.position)
    if not proxy then
      local to_create = {
        name = "item-request-proxy",
        position = entry.container.position,
        target = entry.container,
        force = entry.container.force,
        modules = {}
      }

      if (missing_sections > 0) then
        local down_from = #container_inventory - 2 +1 -- we start iterating at 1
        local in_inventory = {}

        for i = 1, missing_sections do
          in_inventory[i] = {inventory = defines.inventory.chest, stack = down_from - i, count = 1}
        end

        table.insert(to_create.modules, {
          id = {name = "se-cargo-rocket-section"},
          items = {in_inventory = in_inventory}
        })
      end

      if (missing_capsules > 0) then
        table.insert(to_create.modules, {
          id = {name = "se-space-capsule"},
          items = {in_inventory = {
            {inventory = defines.inventory.chest, stack = #container_inventory - 1, count = 1}
          }}
        })
      end

      entry.container.surface.create_entity(to_create)
    end
  end
end

function silo.every_10_seconds()
  for unit_number, entry in pairs(storage.cargo_silo_entries) do

    if entry.container and entry.container.valid then
      silo.random_tick(entry)
    else
      storage.cargo_silo_entries[unit_number] = nil
    end

  end
end

function silo.on_rocket_silo_status_changed(event)
  if event.rocket_silo.name ~= "se-rocket-launch-pad-silo" then return end
  if event.old_status ~= defines.rocket_silo_status.doors_closing then return end

  local container = event.rocket_silo.surface.find_entity("se-rocket-launch-pad", event.rocket_silo.position)
  local entry = storage.cargo_silo_entries[container.unit_number]

  silo.random_tick(entry)
end

return silo
