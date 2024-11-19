local mod_prefix = "keep-off-the-grass-and-off-my-planet-silly-goose-"

local function is_surface_hidden_for(surface, player)
  if surface.planet then
    if prototypes.space_location[surface.planet.name].hidden then
      return true
    end
  end

  return player.force.get_surface_hidden(surface)
end

script.on_init(function()
  storage.surfacedata = {}
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.surfacedata[event.surface_index] = nil
end)

script.on_event(defines.events.on_player_removed, function(event)
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    surfacedata.blacklisted_players[event.player_index] = nil
  end
end)

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
    column_count = 3,
    draw_vertical_lines = true,
    draw_horizontal_lines = true,
  }

  local player_names = {"toggle player"}
  for _, player in pairs(game.players) do
    table.insert(player_names, player.name)
  end

  for _, surface in pairs(game.surfaces) do
    local editor_style_surface_name = surface.name
    if surface.localised_name then editor_style_surface_name = {"", editor_style_surface_name, " (", surface.localised_name, ")"} end
    if surface.platform then editor_style_surface_name = string.format("%s (%s)", editor_style_surface_name, surface.platform.name) end
    if surface.planet then editor_style_surface_name = string.format("%s ([planet=%s] %s)", editor_style_surface_name, surface.planet.name, surface.planet.name) end
    local gui_surface_name = gui_table.add{
      type = "label",
      caption = editor_style_surface_name,
    }
    gui_surface_name.style.margin = 4
    if is_surface_hidden_for(surface, player) then gui_surface_name.style = "grey_label" end

    local piston = gui_table.add{
      type = "flow",
    }
    piston.style.horizontally_stretchable = true

    local surfacedata = storage.surfacedata[surface.index]
    if surfacedata then
      for player_index, _ in pairs(surfacedata.blacklisted_players) do
        local gui_player_name = piston.add{
          type = "label",
          caption = game.get_player(player_index).name,
        }
        gui_player_name.style.margin = 4
      end
    end

    gui_table.add{
      type = "drop-down",
      tags = {action = mod_prefix .. "blacklist-player", surface_index = surface.index},
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

local function update_groundskeeper_gui_for_everyone()
  for _, player in pairs(game.players) do
    if player.gui.screen[mod_prefix .. "frame"] then
      open_for_player(player)
    end
  end
end

local function get_or_create_surfacedata(surface_index)
  local surfacedata = storage.surfacedata[surface_index]
  if surfacedata == nil then
    surfacedata = {
      blacklisted_players = {}
    }
    storage.surfacedata[surface_index] = surfacedata
  end
  return surfacedata
end

local function try_to_blacklist_player_from(player_index, surface_index)
  assert(player_index)
  assert(surface_index)

  if game.surfaces[surface_index] and game.get_player(player_index) then
    get_or_create_surfacedata(surface_index).blacklisted_players[player_index] = true
    update_groundskeeper_gui_for_everyone()
  end
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if event.element.tags.action == mod_prefix .. "blacklist-player" then
    local player_name = event.element.items[event.element.selected_index]
    local player = game.get_player(player_name)
    try_to_blacklist_player_from(player.index, event.element.tags.surface_index)
  end
end)
