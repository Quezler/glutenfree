local mod_prefix = "keep-off-the-grass-and-off-my-planet-silly-goose-"

local function open_for_player(player)
  local frame = player.gui.screen[mod_prefix .. "frame"]
  if frame then frame.destroy() end

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
  scroll_pane.style.minimal_width = 500

  local label_1 = scroll_pane.add{
    type = "label",
    style = "caption_label",
    caption = "surfaces will go here.",
  }

  player.opened = frame
  frame.force_auto_center()
end

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == mod_prefix .. "shortcut" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    open_for_player(player)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    event.element.destroy()
  end
end)
