local mod_prefix = "keep-off-the-grass-and-off-my-planet-silly-goose-"

local function is_surface_hidden_for(surface, player)
  if surface.planet then
    if prototypes.space_location[surface.planet.name].hidden then
      return true
    end
  end

  return player.force.get_surface_hidden(surface)
end

local function open_for_player(player)
  local frame = player.gui.screen[mod_prefix .. "frame"]
  if frame then frame.destroy() end

  player.set_shortcut_toggled(mod_prefix .. "shortcut", true)

  frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "frame",
    direction = "vertical",
    caption = {"mod-gui.keep-off-the-grass-and-off-my-planet-silly-goose"}
  }

  local scroll_pane = frame.add{
    type = "scroll-pane",
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never",
  }
  scroll_pane.style.minimal_width = 1000
  scroll_pane.style.maximal_height = 700


  local gui_table = scroll_pane.add{
    type = "table",
    -- style = "table_with_selection",
    column_count = 2,
    draw_vertical_lines = true,
    draw_horizontal_lines = true,
  }

  for _, surface in pairs(game.surfaces) do
    local editor_style_surface_name = surface.name
    if surface.localised_name then editor_style_surface_name = {"", editor_style_surface_name, " (", surface.localised_name, ")"} end
    if surface.platform then editor_style_surface_name = string.format("%s (%s)", editor_style_surface_name, surface.platform.name) end
    if surface.planet then editor_style_surface_name = string.format("%s ([planet=%s] %s)", editor_style_surface_name, surface.planet.name, surface.planet.name) end
    local gui_surface_name = gui_table.add{
      type = "label",
      caption = editor_style_surface_name,
    }
    if is_surface_hidden_for(surface, player) then gui_surface_name.style = "grey_label" end

    local player_names = {"select a player"}
    for _, player in pairs(game.players) do
      table.insert(player_names, player.name)
    end
    gui_table.add{
      type = "drop-down",
      items = player_names,
      selected_index = 1,
    }
  end

  player.opened = frame
  frame.force_auto_center()
end

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == mod_prefix .. "shortcut" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    if player.is_shortcut_toggled(mod_prefix .. "shortcut") then
      player.gui.screen[mod_prefix .. "frame"].destroy()
      player.set_shortcut_toggled(mod_prefix .. "shortcut", false)
    else
      open_for_player(player)
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.gui.screen[mod_prefix .. "frame"].destroy()
    player.set_shortcut_toggled(mod_prefix .. "shortcut", false)
  end
end)
