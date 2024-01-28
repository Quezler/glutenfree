local _global = {player_should_open = {}}

script.on_init(function(event)
  global.wagon_number_to_tank = {}
  global.tank_number_to_wagon = {}
end)

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

  global.wagon_number_to_tank[entity.unit_number] = tank
  global.tank_number_to_wagon[tank.unit_number] = entity

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

script.on_event(defines.events.on_tick, function(event)
  for _, connected_player in ipairs(game.connected_players) do
    if connected_player.opened and connected_player.opened.unit_number then
      local wagon = global.tank_number_to_wagon[connected_player.opened.unit_number]
      local tank = connected_player.opened
      if wagon then
        local fluid = wagon.fluidbox[1]
        if fluid then
          tank.clear_fluid_inside()
          tank.insert_fluid(fluid)
        end
      end
    end
  end
end)

script.on_event(defines.events.on_player_flushed_fluid, function(event)
  if event.entity.name == 'fluid-wagon-flushable' then
    local wagon = global.tank_number_to_wagon[event.entity.unit_number]
    wagon.clear_fluid_inside()
  end
end)
