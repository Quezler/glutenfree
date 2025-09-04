script.on_init(function()
  storage.centered_on_next_tick = {}
end)

local function on_tick()
  for playe_index, struct in pairs(storage.centered_on_next_tick) do
    if struct.player.valid and struct.entity.valid and struct.times > 0 then
      struct.player.centered_on = struct.entity
      struct.times = struct.times - 1
    else
      storage.centered_on_next_tick[playe_index] = nil
    end
  end

  if next(storage.centered_on_next_tick) == nil then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function()
  if next(storage.centered_on_next_tick) ~= nil then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.type ~= "camera" then return end

  local entity = event.element.entity
  if entity == nil then return end -- untargeted beam?
  if entity.name ~= "se-energy-glaive-beam" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.centered_on = entity

  storage.centered_on_next_tick[player.index] = {
    player = player,
    entity = entity,
    times = 2, -- doing it in the next on_tick doesn't seem to cut it, lets try it in the tick after that too.
  }
  script.on_event(defines.events.on_tick, on_tick)
end)
