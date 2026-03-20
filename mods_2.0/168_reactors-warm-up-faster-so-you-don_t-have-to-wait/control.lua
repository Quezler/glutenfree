---@class storage
  ---@field structs table<number, ReactorStruct>

---@class ReactorStruct
  ---@field index number
  ---@field entity LuaEntity
  ---@field max_energy_usage number
  ---@field max_temperature number
  ---@field specific_heat number
  ---@field effectivity number
  ---@field tick number

local one_minute = 60 * 60
local shutoff = 0.5
local rate = 10 - 1

---@param struct ReactorStruct
local function tick_reactor(struct)
  if not struct.entity.valid then
    storage.structs[struct.index] = nil
    return
  end

  if game.tick > (struct.tick + one_minute) then
    storage.structs[struct.index] = nil
    return
  end

  local entity = struct.entity
  if entity.temperature > (struct.max_temperature * shutoff) then
    storage.structs[struct.index] = nil
    return
  end

  -- if entity.position.x > 0 then return end -- debug

  local fuel = entity.burner.remaining_burning_fuel
  if fuel == 0 then return end -- out of fuel

  local per_tick = struct.max_energy_usage
  local multiplier = math.min(rate, fuel / per_tick) -- enough fuel left for this rate

  struct.tick = game.tick -- bump
  local energy = per_tick * multiplier
  local bonus = 1 + entity.neighbour_bonus

  entity.burner.remaining_burning_fuel = entity.burner.remaining_burning_fuel - energy
  entity.temperature = entity.temperature + (energy / struct.specific_heat * struct.effectivity * bonus)
end

local function on_tick(event)
  for _, struct in pairs(storage.structs) do
    tick_reactor(struct)
  end

  if not next(storage.structs) then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if next(storage.structs) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

local function on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.prototype.burner_prototype == nil then return end

  storage.structs[entity.unit_number] = {
    index = entity.unit_number,
    entity = entity,

    max_energy_usage = entity.prototype.get_max_energy_usage(entity.quality),
    max_temperature = entity.prototype.heat_buffer_prototype.max_temperature,
    specific_heat = entity.prototype.heat_buffer_prototype.specific_heat,
    effectivity = entity.prototype.burner_prototype.effectivity,

    tick = event.tick,
  }

  script.on_event(defines.events.on_tick, on_tick)
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local selected = player.selected
  if selected and selected.type == "reactor" then
    on_created_entity({entity = selected, tick = event.tick})
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
  storage.structs = {}
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
