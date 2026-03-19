local one_minute = 60 * 60

local function tick_reactor(struct)
  if struct.entity.valid == false then
    storage.structs_count = storage.structs_count - 1
    storage.structs[struct.unit_number] = nil
    return
  end

  local entity = struct.entity
  local entity_name = entity.name

  if game.tick > struct.tick + one_minute then
    -- game.print("reactor timed out.")
    -- entity.surface.create_entity{
    --   name = "flying-text",
    --   position = entity.position,
    --   text = "reactor timed out.",
    -- }
    storage.structs_count = storage.structs_count - 1
    storage.structs[struct.unit_number] = nil
    return
  end

  if entity.temperature > storage.max_temperature[entity_name] / 2 then
    -- game.print("reactor warmed up.")
    -- entity.surface.create_entity{
    --   name = "flying-text",
    --   position = entity.position,
    --   text = "reactor warmed up.",
    -- }
    storage.structs_count = storage.structs_count - 1
    storage.structs[struct.unit_number] = nil
    return
  end

  local fuel = entity.burner.remaining_burning_fuel
  if fuel == 0 then return end -- not (yet) fueled

  local per_tick = storage.max_energy_usage[entity_name]
  local multiplier = math.min(9, math.max(fuel / per_tick))
  if multiplier == 0 then return end

  struct.tick = game.tick -- prevent the reactor from timing out
  local transfer = per_tick * multiplier * (1 + entity.neighbour_bonus)

  entity.burner.remaining_burning_fuel = entity.burner.remaining_burning_fuel - transfer
  entity.temperature = entity.temperature + (transfer / storage.specific_heat[entity_name] * storage.effectivity[entity_name])
end

local function on_tick(event)
  for unit_number, struct in pairs(storage.structs) do
    tick_reactor(struct)
  end

  if storage.structs_count == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if storage.structs_count > 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

local function on_created_entity(event)
  local entity = event.entity or event.destination

  -- SE energy beam receiver & SE energy beam injector
  if entity.prototype.burner_prototype == nil then return end

  -- case not yet handled (is it * the transfer, or does it also do something to the buffered energy?)
  if entity.prototype.burner_prototype.effectivity ~= 1 then
    game.print(string.format("reactor %s has a fuel effectivity of %f which is not yet supported by the warmup mod, report this please.", entity.prototype.name, entity.prototype.burner_prototype.effectivity))
    return
  end

  storage.structs_count = storage.structs_count + 1
  storage.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
    tick = event.tick,
  }

  script.on_event(defines.events.on_tick, on_tick)
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  if player.selected and player.selected.type == "reactor" and storage.structs[player.selected.unit_number] == nil then
    on_created_entity({entity = player.selected, tick = event.tick})
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "type", type = "reactor"},
  })
end

local function on_configuration_changed(event)
  storage.max_energy_usage = {}
  storage.max_temperature = {}
  storage.specific_heat = {}
  storage.effectivity = {}

  local prototypes = prototypes.get_entity_filtered{{filter="type", type="reactor"}}
  for _, prototype in pairs(prototypes) do
    storage.max_energy_usage[prototype.name] = prototype.get_max_energy_usage()
    storage.max_temperature[prototype.name] = prototype.heat_buffer_prototype.max_temperature
    storage.specific_heat[prototype.name] = prototype.heat_buffer_prototype.specific_heat
    storage.effectivity[prototype.name] = prototype.burner_prototype.effectivity
  end
end

script.on_init(function(event)
  storage.structs = {}
  storage.structs_count = 0
  on_configuration_changed()
end)

script.on_configuration_changed(on_configuration_changed)

-- commands.add_command("reactors-warm-up-faster-debug", nil, function(command)
--   local player = game.get_player(command.player_index)

--   player.print(serpent.block({
--     structs_count = storage.structs_count,
--   }))
-- end)
