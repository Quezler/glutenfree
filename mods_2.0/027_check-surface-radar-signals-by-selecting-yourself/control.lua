local mod_prefix = 'csrsbsy-'

script.on_init(function()
  storage.structs = {}
end)

commands.add_command('proxy-me', nil, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.surface.create_entity{
    name = mod_prefix .. "item-request-proxy",
    force = player.force,
    position = player.position,

    target = player.character,

    -- `{inventory = 255, stack = 0}` is not needed apparently to keep the proxy alive,
    -- neat because it stops the missing items alert when outside roboport range.
    modules = {{id = {name = "radar"}, items = {in_inventory = {} }}}
  }
end)

local function selected_by_anyone(entity)
  for _, player in ipairs(game.connected_players) do
    if player.selected == entity then return true end
  end
end

local function on_tick(event)
  for struct_id, struct in pairs(storage.structs) do
    if (not struct.proxy.valid) or (not struct.pole.valid) or ((not selected_by_anyone(struct.pole)) and (not selected_by_anyone(struct.proxy))) then
      -- struct.proxy.destroy()
      struct.pole.destroy()
      storage.structs[struct_id] = nil
      goto continue
    end

    struct.pole.teleport(struct.proxy.position)

    ::continue::
  end

  if next(storage.structs) == nil then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected

  if entity and entity.name == mod_prefix .. "item-request-proxy" then
    -- when running/lagging you might be able to select the proxy whilst the pole is not aligned
    -- assert(storage.structs[entity.unit_number] == nil)
    if storage.structs[entity.unit_number] == nil then
      local pole = entity.surface.create_entity{
        name = mod_prefix .. "electric-pole",
        force = entity.force,
        position = entity.position,
      }

      assert(pole)
      local pole_red   = pole.get_wire_connector(defines.wire_connector_id.circuit_red  , true)
      local pole_green = pole.get_wire_connector(defines.wire_connector_id.circuit_green, true)

      local radars = entity.surface.find_entities_filtered{
        type = "radar",
        force = entity.force,
      }
      for _, radar in ipairs(radars) do
        -- game.print(radar.unit_number)

        local radar_red   = radar.get_wire_connector(defines.wire_connector_id.circuit_red  , false)
        local radar_green = radar.get_wire_connector(defines.wire_connector_id.circuit_green, false)

        game.print('red '   .. serpent.line(radar_red  ))
        game.print('green ' .. serpent.line(radar_green))

        -- radar.get_wire_connector(defines.wire_connector_id.circuit_red  , true).connect_to(pole_red  , false, defines.wire_origin.script)
        -- radar.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(pole_green, false, defines.wire_origin.script)
      end

      storage.structs[entity.unit_number] = {
        proxy = entity,
        pole = pole,
      }

      script.on_event(defines.events.on_tick, on_tick)
    end
  end
end)

script.on_load(function()
  if next(storage.structs) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)
