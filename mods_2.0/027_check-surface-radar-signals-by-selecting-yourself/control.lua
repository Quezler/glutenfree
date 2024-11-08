local mod_prefix = 'csrsbsy-'

script.on_init(function()
  storage.structs = {}

  storage.proxy_for_character = {}
end)

local function proxy_me(player)
  local character = player.character
  if character == nil then return end
  if storage.proxy_for_character[character.unit_number] and storage.proxy_for_character[character.unit_number].valid then return end

  local proxy = character.surface.create_entity{
    name = mod_prefix .. "item-request-proxy",
    force = character.force,
    position = character.position,

    target = character,

    -- `{inventory = 255, stack = 0}` is not needed apparently to keep the proxy alive,
    -- neat because it stops the missing items alert when outside roboport range.
    modules = {{id = {name = "radar"}, items = {in_inventory = {} }}}
  }

  storage.proxy_for_character[character.unit_number] = proxy
end

-- commands.add_command('proxy-me', nil, function(event)
  -- local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  -- proxy_me(player.character)
-- end)

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
        name = "radar",
        force = entity.force,
      }
      for _, radar in ipairs(radars) do
        radar.get_wire_connector(defines.wire_connector_id.circuit_red  , true).connect_to(pole_red  , false, defines.wire_origin.script)
        radar.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(pole_green, false, defines.wire_origin.script)
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

-- just make sure everyone has one every so often
script.on_nth_tick(600, function(event)
  for _, player in ipairs(game.connected_players) do
    proxy_me(player)
  end
end)

-- swapping your armor slot purges the proxy
script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  proxy_me(player)
end)
