require("shared")

local mod = {}

local get_default_inventory_size = {}

for _, entity in pairs(prototypes.get_entity_filtered{{filter = "type", type = "cargo-wagon"}}) do
  get_default_inventory_size[entity.name] = {}

  for _, quality in pairs(prototypes.quality) do
    get_default_inventory_size[entity.name][quality.name] = entity.get_inventory_size(defines.inventory.cargo_wagon, quality)
  end
end

-- function mod.reset_whitelist()
--   storage.whitelist = storage.whitelist or {}

--   mod.add_to_whitelist("cargo-wagon")
-- end

script.on_init(function(event)
  storage.whitelist = {}
  storage.cargo_wagons = {}
  -- mod.reset_whitelist()

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "cargo-wagon"})) do
      on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function(event)
  -- mod.reset_whitelist()
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  storage.cargo_wagons[entity.unit_number] = {
    entity = entity,
  }
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

function mod.tick_force(force)
  local belt_stack_size_bonus = force.belt_stack_size_bonus

  for unit_number, cargo_wagon in pairs(storage.cargo_wagons) do
    if not cargo_wagon.entity.valid then
      storage.cargo_wagons[unit_number] = nil
    else
      local default_inventory_size = get_default_inventory_size[cargo_wagon.entity.name][cargo_wagon.entity.quality.name]
      cargo_wagon.entity.set_inventory_size_override(defines.inventory.cargo_wagon, default_inventory_size * belt_stack_size_bonus)
    end
  end
end

-- /cheat all
-- /c game.player.force.belt_stack_size_bonus = 5
function mod.on_belt_stack_size_changed(event)
  if event.player_index then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    mod.tick_force(player.force)
    -- game.print('command: ' .. player.force.belt_stack_size_bonus)
  elseif event.research then
    mod.tick_force(event.research.force)
    -- game.print('research: ' .. event.research.force.belt_stack_size_bonus)
  end
end

for _, event in ipairs({
  defines.events.on_research_finished,
  defines.events.on_research_reversed,
  defines.events.on_console_command,
}) do
  script.on_event(event, mod.on_belt_stack_size_changed)
end

function mod.get_whitelist()
  return storage.whitelist
end

function mod.add_to_whitelist(entity_name)
  assert(storage.whitelist[entity_name] == nil)
  storage.whitelist[entity_name] = true
  game.print(entity_name)
end

function mod.remove_from_whitelist(entity_name)
  assert(storage.whitelist[entity_name] == true)
  storage.whitelist[entity_name] = nil
end

remote.add_interface(mod_name, {
  get_whitelist = mod.get_whitelist,
  add_to_whitelist = mod.add_to_whitelist,
  remove_from_whitelist = mod.remove_from_whitelist,
})

-- /c remote.call("cargo-wagons-benefit-from-belt-stack-size-bonuses", "add_to_whitelist", "cargo-wagon")
