local Zone = require('__space-exploration-scripts__.zone')

local mod_prefix = "" -- should be `aai-` for versions after v0.4.9
local default_channel = "Default"

script.on_init(function(event)
  global.player_keystrokes_since_editing_channel = {}
end)

script.on_configuration_changed(function(event)
  global.player_keystrokes_since_editing_channel = global.player_keystrokes_since_editing_channel or {}
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.name == mod_prefix .. "change_channel" then
    global.player_keystrokes_since_editing_channel[event.player_index] = 0
    if event.element.parent.children[1].caption == default_channel then
      local player = game.get_player(event.player_index)
      local coin = {name = "coin", count = 1}
      if player.get_main_inventory().insert(coin) then
        player.get_main_inventory().remove(coin)
      end
    end
  end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index)
  local opened = player.opened

  if opened and opened.object_name == "LuaGuiElement" and opened.name == "aai-signal-sender" then
    local write_channel = opened.children[2].children[2].children[1].children[1]
    if write_channel.type ~= "textfield" then return end -- for freshly constructed ones
    if write_channel.text ~= default_channel then return end

    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = player.surface.index})
    if not zone then return end

    write_channel.text = Zone._get_rich_text_name(zone)
    write_channel.select_all()
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element and event.element.name == mod_prefix .. "write-channel" then
    global.player_keystrokes_since_editing_channel[event.player_index] = global.player_keystrokes_since_editing_channel[event.player_index] + 1

    if event.element.text == "" and global.player_keystrokes_since_editing_channel[event.player_index] == 1 then
      local player = game.get_player(event.player_index)
      
      local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = player.surface.index})
      if not zone then return end
  
      event.element.text = Zone._get_rich_text_name(zone)
      event.element.select_all()
    end
  end
end)
