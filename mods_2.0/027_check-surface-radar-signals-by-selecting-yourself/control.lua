local mod_prefix = 'csrsbsy-'

script.on_init(function()

end)

-- script.on_event(defines.events.on_player_changed_position, function(event)
--   game.print(event.tick)
-- end)

-- script.on_event(defines.events.on_tick, function(event)
--   local player = game.get_player("Quezler") --[[@as LuaPlayer]]
-- end)

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

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected

  if entity and entity.name == mod_prefix .. "item-request-proxy" then
    entity.surface.create_entity{
      name = mod_prefix .. "electric-pole",
      force = entity.force,
      position = entity.position,
    }
  end
end)
