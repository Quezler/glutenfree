local poles = {}

--

function poles.init()
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = "se-addon-power-pole"})) do -- skips ghosts, not on purpose
      poles.random_tick(entity)
    end
  end
end

function poles.on_created_entity(event)
  local entity = event.entity or event.destination

  poles.random_tick(entity)
end

function poles.random_tick(entity)
  -- game.print(serpent.block( entity.position ))

  -- double them so we can use 0.5
  local x = entity.position.x * 2
  local y = entity.position.y * 2

  -- move only if snaped
  local teleport = false

  -- snap x
  if (x % 1) > 0.5 then
    x = math.ceil(x)
    teleport = true
  elseif (x % 1) < 0.5 then
    x = math.floor(x)
    teleport = true
  end

  -- snap y
  if (y % 1) > 0.5 then
    y = math.ceil(y)
    teleport = true
  elseif (y % 1) < 0.5 then
    y = math.floor(y)
    teleport = true
  end

  -- teleport
  if teleport then
    entity.teleport({
      x = x / 2,
      y = y / 2,
    })
  end
end

--

return poles
