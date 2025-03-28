local _storage = {player_should_open = {}}

local function on_configuration_changed()
  storage.is_flushable = {}
  for entity_name, prototype in pairs(prototypes.get_entity_filtered({{filter = "type", type = "fluid-wagon"}})) do
    storage.is_flushable[entity_name .. "-flushable"] = true
  end
end

script.on_init(function(event)
  storage.structs = {}
  storage.structs_count = 0
  storage.tank_number_to_wagon = {}
  on_configuration_changed()
end)

script.on_configuration_changed(on_configuration_changed)

local function tick_struct(struct)
  if struct.tank.valid == false then return false, "tank.valid" end
  if struct.wagon.valid == false then return false, "wagon.valid" end

  if struct.player.opened == struct.wagon then return true end
  if struct.player.opened ~= struct.tank then return false, "opened ~= tank" end
  assert(struct.player.connected) -- can opened be non-nil if a player is offline?

  local fluid_name, fluid_amount = next(struct.wagon.get_fluid_contents())
  -- game.print(fluid_name .. fluid_amount)
  if fluid_name then
    -- struct.tank.clear_fluid_inside()
    struct.tank.insert_fluid({name = fluid_name, amount = fluid_amount})
  end

  if struct.tank.position ~= struct.wagon.position then
    -- struct.tank.teleport(struct.wagon.position)
  end
end

local function on_tick(event)
  for unit_number, struct in pairs(storage.structs) do
    local keep, why = tick_struct(struct)
    -- if keep == false then
    --   game.print(why)
    --   struct.tank.destroy()
    --   storage.tank_number_to_wagon[struct.tank_unit_number] = nil

    --   storage.structs[unit_number] = nil
    --   storage.structs_count = storage.structs_count - 1
    -- end
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

---@param event EventData.CustomInputEvent
script.on_event("open-fluid-wagon", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local entity = player.selected
  if entity == nil then return end
  if entity.type ~= "fluid-wagon" then return end

  local fluid_name, fluid_amount = next(entity.get_fluid_contents())
  if fluid_name == nil then return end -- empty fluid wagon (to allow access to equipment)

  local tank = entity.surface.create_entity{
    name = entity.name .. "-flushable",
    force = entity.force,
    position = entity.position,
  }

  assert(tank)
  tank.destructible = false
  tank.insert_fluid({name = fluid_name, amount = fluid_amount})

  _storage.player_should_open[player.index] = tank
  storage.tank_number_to_wagon[tank.unit_number] = entity

  storage.structs[tank.unit_number] = { -- tank's unit number so multiple per wagon can exist
    wagon_unit_number = entity.unit_number,
    wagon = entity,

    tank_unit_number = tank.unit_number,
    tank = tank,

    player = player,
  }

  storage.structs_count = storage.structs_count + 1
  script.on_event(defines.events.on_tick, on_tick)

  local coin = {name = "coin", count = 1}
  if player.get_main_inventory().insert(coin) then
    player.get_main_inventory().remove(coin)
  end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local tank = _storage.player_should_open[player.index]
  if tank == nil then return end
  _storage.player_should_open[player.index] = nil

  if tank.valid == false then return end
  player.opened = tank
end)

script.on_event(defines.events.on_player_flushed_fluid, function(event)
  if storage.is_flushable[event.entity.name] then
    local wagon = storage.tank_number_to_wagon[event.entity.unit_number]
    wagon.clear_fluid_inside()
  end
end)

-- /c game.print(game.player.opened.get_fluid_contents()["water"])
-- /c game.player.opened.insert_fluid({name = "water", amount = 50000})

-- /c script.on_event(defines.events.on_tick, function(event)
--   for _, player in pairs(game.players) do
--     if player.opened and player.opened.name == "storage-tank" then
--       game.print(event.tick)
--       player.opened.clear_fluid_inside()
--       player.opened.insert_fluid({name = "water", amount = 50000})
--     end
--   end
-- end)
