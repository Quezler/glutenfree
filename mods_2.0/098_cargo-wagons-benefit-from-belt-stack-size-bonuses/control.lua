require("shared")

local mod = {}

local get_default_inventory_size = {}
for _, entity in pairs(prototypes.get_entity_filtered{{filter = "type", type = "cargo-wagon"}}) do
  get_default_inventory_size[entity.name] = {}

  for _, quality in pairs(prototypes.quality) do
    get_default_inventory_size[entity.name][quality.name] = entity.get_inventory_size(defines.inventory.cargo_wagon, quality)
  end
end

script.on_init(function(event)
  storage.cargo_wagons = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "cargo-wagon"})) do
      on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function(event)
  mod.on_belt_stack_size_changed()
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  storage.cargo_wagons[entity.unit_number] = {
    entity = entity,
  }

  mod.tick_cargo_wagon(storage.cargo_wagons[entity.unit_number])
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
    {filter = "type", type = "cargo-wagon"},
  })
end

function mod.tick_cargo_wagon(cargo_wagon)
  local entity = cargo_wagon.entity
  local belt_stack_size_bonus = entity.force.belt_stack_size_bonus

  local default_inventory_size = get_default_inventory_size[entity.name][entity.quality.name]
  local current_inventory_size = entity.get_inventory_size_override(defines.inventory.cargo_wagon) or default_inventory_size
  local next_inventory_size = default_inventory_size * belt_stack_size_bonus
  if current_inventory_size > next_inventory_size then
    local slot_difference = math.abs(next_inventory_size - current_inventory_size)
    local inventory = game.create_inventory(slot_difference)
    entity.set_inventory_size_override(defines.inventory.cargo_wagon, default_inventory_size * belt_stack_size_bonus, inventory)
    for slot = 1, #inventory do
      local stack = inventory[slot]
      if stack.valid_for_read then
        entity.surface.spill_item_stack{
          position = entity.position,
          stack = stack,
          force = entity.force,
          allow_belts = false,
          drop_full_stack = true,
        }
      end
    end
    inventory.destroy()
  else
    entity.set_inventory_size_override(defines.inventory.cargo_wagon, default_inventory_size * belt_stack_size_bonus)
  end
end

-- /cheat all
-- /c game.player.force.belt_stack_size_bonus = 5
function mod.on_belt_stack_size_changed(event)
  for unit_number, cargo_wagon in pairs(storage.cargo_wagons) do
    if not cargo_wagon.entity.valid then
      storage.cargo_wagons[unit_number] = nil
    else
      mod.tick_cargo_wagon(cargo_wagon)
    end
  end
end

for _, event in ipairs({
  defines.events.on_research_finished,
  defines.events.on_research_reversed,
  defines.events.on_console_command,
}) do
  script.on_event(event, mod.on_belt_stack_size_changed)
end
