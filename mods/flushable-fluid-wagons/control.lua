local _global = {player_should_open = {}}

script.on_event('open-fluid-wagon', function(event)
  local player = game.get_player(event.player_index)

  local entity = player.selected
  if entity == nil then return end
  if entity.type ~= 'fluid-wagon' then return end

  local fluid = entity.fluidbox[1]
  -- if fluid == nil then return end -- empty fluid wagon

  game.print(entity.name)

  local tank = entity.surface.create_entity{
    name = entity.name .. '-flushable',
    force = entity.force,
    position = entity.position,
  }

  tank.destructible = false
  if fluid then
    tank.insert_fluid(fluid)
  end

  _global.player_should_open[player.index] = tank

  local coin = {name = "coin", count = 1}
  if player.get_main_inventory().insert(coin) then
    player.get_main_inventory().remove(coin)
  end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index)

  local tank = _global.player_should_open[player.index]
  if tank == nil then return end
  _global.player_should_open[player.index] = nil
  player.opened = tank
end)
