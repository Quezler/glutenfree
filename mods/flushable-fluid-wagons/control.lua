local _global = {player_should_open = {}}

script.on_init(function(event)
  global.structs = {}

  -- global.wagon_number_to_tank = {}
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

  -- global.wagon_number_to_tank[entity.unit_number] = tank
  global.tank_number_to_wagon[tank.unit_number] = entity

  global.structs[tank.unit_number] = { -- tank unit number so multiple per wagon can exist
    wagon_unit_number = entity.unit_number,
    wagon = entity,

    tank_unit_number = tank.unit_number,
    tank = tank,

    player = player,
  }

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

local function tick_struct(struct)
  if struct.tank.valid == false then return false, debug.getinfo(1).currentline end
  if struct.wagon.valid == false then return false, debug.getinfo(1).currentline end

  if struct.player.opened == struct.wagon then return true, "we'll wait for the next tick" end
  if struct.player.opened ~= struct.tank then return false, debug.getinfo(1).currentline end
  assert(struct.player.connected) -- can opened be non-nil if a player is offline?

  local fluid = struct.wagon.fluidbox[1]
  if fluid then
    struct.tank.clear_fluid_inside()
    struct.tank.insert_fluid(fluid)
  end

  return true
end

script.on_event(defines.events.on_tick, function(event)
  for unit_number, struct in pairs(global.structs) do
    local keep, why = tick_struct(struct)
    if keep == false then
      -- log(why)
      -- log(struct.player.opened.name)
      struct.tank.destroy()
      -- struct.wagon.destroy()

      -- global.wagon_number_to_tank[struct.wagon_unit_number] = nil
      global.tank_number_to_wagon[struct.tank_unit_number] = nil
    end
  end
end)

script.on_event(defines.events.on_player_flushed_fluid, function(event)
  if event.entity.name == 'fluid-wagon-flushable' then
    local wagon = global.tank_number_to_wagon[event.entity.unit_number]
    wagon.clear_fluid_inside()
  end
end)
