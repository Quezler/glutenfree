local _global = {player_should_open = {}}

local function on_configuration_changed()
  global.is_flushable = {}
  for entity_name, prototype in pairs(game.get_filtered_entity_prototypes({{filter = 'type', type = 'fluid-wagon'}})) do
    global.is_flushable[entity_name .. '-flushable'] = true
  end
end

script.on_init(function(event)
  global.structs = {}
  global.structs_count = 0
  global.tank_number_to_wagon = {}
  on_configuration_changed()
end)

script.on_configuration_changed(on_configuration_changed)

local function tick_struct(struct)
  if struct.tank.valid == false then return false end
  if struct.wagon.valid == false then return false end

  if struct.player.opened == struct.wagon then return true end
  if struct.player.opened ~= struct.tank then return false end
  assert(struct.player.connected) -- can opened be non-nil if a player is offline?

  local fluid = struct.wagon.fluidbox[1]
  if fluid then
    struct.tank.clear_fluid_inside()
    struct.tank.insert_fluid(fluid)
  end
end

local function on_tick(event)
  for unit_number, struct in pairs(global.structs) do
    local keep, why = tick_struct(struct)
    if keep == false then
      struct.tank.destroy()
      global.tank_number_to_wagon[struct.tank_unit_number] = nil

      global.structs[unit_number] = nil
      global.structs_count = global.structs_count - 1
    end
  end

  if global.structs_count == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if global.structs_count > 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event('open-fluid-wagon', function(event)
  local player = game.get_player(event.player_index)

  local entity = player.selected
  if entity == nil then return end
  if entity.type ~= 'fluid-wagon' then return end

  local fluid = entity.fluidbox[1]
  if fluid == nil then return end -- empty fluid wagon (to allow access to equipment)

  local tank = entity.surface.create_entity{
    name = entity.name .. '-flushable',
    force = entity.force,
    position = entity.position,
  }

  tank.destructible = false
  tank.insert_fluid(fluid)

  _global.player_should_open[player.index] = tank
  global.tank_number_to_wagon[tank.unit_number] = entity

  global.structs[tank.unit_number] = { -- tank's unit number so multiple per wagon can exist
    wagon_unit_number = entity.unit_number,
    wagon = entity,

    tank_unit_number = tank.unit_number,
    tank = tank,

    player = player,
  }

  global.structs_count = global.structs_count + 1
  script.on_event(defines.events.on_tick, on_tick)

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

script.on_event(defines.events.on_player_flushed_fluid, function(event)
  if global.is_flushable[event.entity.name] then
    local wagon = global.tank_number_to_wagon[event.entity.unit_number]
    wagon.clear_fluid_inside()
  end
end)
