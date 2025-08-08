script.on_event(defines.events.on_gui_click, function(event)
  if not event.element.valid then return end
  if event.element.tags.action ~= "confirm-extinction" then return end

  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.element.tags.zone_index})
  local surface = game.get_surface(zone.surface_index) --[[@as LuaSurface]]

  local enemies = surface.find_entities_filtered{
    force = "enemy", -- currently no support for SE's enemy_forces(force) for pvp scenarios and god knows which other mods
    type = {"unit-spawner", "turret"},
  }

  if #enemies == 0 then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.create_local_flying_text{
    text = tostring(#enemies) .. " nests/worms left", -- don't care about singular since it'll only be 1 for like a second
    create_at_cursor = true,
  }
end)
