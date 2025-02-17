require("shared")

local function about_space_platform_hub(event)
  -- game.print(serpent.block(event.selected_prototype))
  return event.selected_prototype and event.selected_prototype.derived_type == "space-platform-hub"
end

script.on_event(mod_prefix .. "cycle-quality-up", function(event)
  if not about_space_platform_hub(event) then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local hub = player.surface.platform.hub --[[@as LuaEntity]]

  rendering.draw_sprite{
    surface = player.surface,
    sprite = mod_prefix .. "platform-hub-3",
    target = hub,
    render_layer = "cargo-hatch",
    time_to_live = 60 * 5,
  }

  rendering.draw_sprite{
    surface = player.surface,
    sprite = mod_prefix .. "platform-upper-hatch-occluder",
    target = hub,
    render_layer = "item-in-inserter-hand",
    time_to_live = 60 * 5,
  }
end)

script.on_event(mod_prefix .. "cycle-quality-down", function(event)
  if not about_space_platform_hub(event) then return end
end)
