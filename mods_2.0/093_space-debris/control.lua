local mod = {}

script.on_init(function()
  storage.platformdata = {}
  mod.refresh_platformdata()
end)

script.on_configuration_changed(function()
  mod.refresh_platformdata()
end)

function mod.refresh_platformdata()
  -- deleted old
  for surface_index, platformdata in pairs(storage.platformdata) do
    if platformdata.surface.valid == false then
      storage.platformdata[surface_index] = nil
    else
      assert(platformdata.platform.valid)
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    if surface.platform then
      storage.platformdata[surface.index] = storage.platformdata[surface.index] or {
        surface = surface,
        platform = surface.platform,
      }
    end
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_platformdata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_platformdata)

script.on_nth_tick(60 * 5, function(event)
  for _, platformdata in pairs(storage.platformdata) do
    -- log(serpent.line(platformdata.platform.ejected_items))
    log(#platformdata.platform.ejected_items)
  end
end)

function mod.cover_me_in_debris(asteroid)
  for i = 1, 10 do
    rendering.draw_sprite{
      sprite = "item/" .. "rail",
      x_scale = 0.5,
      y_scale = 0.5,
      target = {entity = asteroid, offset = {
        math.random() - 0.5,
        math.random() - 0.5,
      }},
      surface = asteroid.surface,
      orientation = math.random(),
      orientation_target = {0, 0},
      -- use_target_orientation = true,
    }
  end
end

commands.add_command("cover-me-in-debris", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local selected = player.selected
  if selected and selected.type == "asteroid" then
    mod.cover_me_in_debris(selected)
  end
end)
