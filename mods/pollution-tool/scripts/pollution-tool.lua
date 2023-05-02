local pollution_tool = {}

local ticks_per_second, seconds_per_minute = 60, 60

local function round(number, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function pollution_tool.per_minute(entity)
  if entity.name == "tile-ghost" or entity.name == "entity-ghost" then
    return 0
  end

  local energy_multiplier, pollution_multiplier = 1, 1

  if entity.effects then
    if entity.effects["consumption"] then energy_multiplier = 1 + entity.effects["consumption"].bonus end
    if entity.effects["pollution"] then pollution_multiplier = 1 + entity.effects["pollution"].bonus end
  end

  if entity.prototype.electric_energy_source_prototype then
    return (entity.prototype.electric_energy_source_prototype.emissions * pollution_multiplier) * (entity.prototype.max_energy_usage * energy_multiplier) * (ticks_per_second * seconds_per_minute)
  else
    game.print("Cannot determine the pollution of: " .. entity.name)
    return 0
  end
end

function pollution_tool.on_player_selected_area(event)

  local purifier_pollution = game.entity_prototypes["kr-air-purifier"].electric_energy_source_prototype.emissions * game.entity_prototypes["kr-air-purifier"].max_energy_usage * (ticks_per_second * seconds_per_minute)

  local pollution = 0
  for _, entity in pairs(event.entities) do
    pollution = pollution + pollution_tool.per_minute(entity)
  end

  local purifiers = 0
  if pollution ~= 0 then
    purifiers = math.ceil(pollution / (-purifier_pollution))
    if purifiers == -0 then purifiers = 0 end
  end

  local player = game.get_player(event.player_index)
  local text = {}
  text[1] = "[item=kr-air-purifier]"
  text[2] = round(pollution, 2)
  text[3] = "/"
  text[4] = -purifier_pollution
  text[5] = "="
  text[6] = purifiers
  player.create_local_flying_text({text = table.concat(text, " "), create_at_cursor = true})
end

return pollution_tool
