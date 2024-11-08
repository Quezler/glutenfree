local mod_prefix = 'csrsbsy-'

script.on_init(function()
  storage.index = 0
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

    struct.pole.teleport(struct.proxy.proxy_target.position)

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
    local pole = entity.surface.create_entity{
      name = mod_prefix .. "electric-pole",
      force = entity.force,
      position = entity.position,
    }

    storage.index = storage.index + 1
    storage.structs[storage.index] = {
      proxy = entity,
      pole = pole,
    }

    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_load(function()
  if next(storage.structs) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)
