local mod = {}

mod.button_name = "qpgopgbc-button"

script.on_init(function()
  for _, player in pairs(game.players) do
    mod.on_player_created({player_index = player.index})
  end
  log("foo")
end)

local button_size = 40
local sidemenu_margin = 8
local research_height_off = 40

---@param player LuaPlayer
---@return GuiLocation
function mod.get_location(player)
  local scale = player.display_scale
  local resolution = player.display_resolution

  local top_offset = 0
  local right_offset = 0

  if player.controller_type == defines.controllers.remote then
    top_offset = 36 + 4
    right_offset = 8 + 4
  end

  return {
    resolution.width - (right_offset + sidemenu_margin + button_size + button_size + button_size + button_size) * scale,
    (top_offset + sidemenu_margin + research_height_off + sidemenu_margin + button_size) * scale,
  }
end

---@return number?
function mod.get_number()
  local online_players = #game.connected_players

  if 1 >= online_players then
    return nil
  end

  return online_players - 1
end

function mod.on_player_created(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local button = player.gui.screen.add{
    type = "sprite-button",
    name = mod.button_name,
    style = "transparent_button",
    ignored_by_interaction = true,
  }
  button.style.width = button_size
  button.style.height = button_size
  button.style.padding = 4

  button.number = mod.get_number()
  button.location = mod.get_location(player)
end

script.on_event(defines.events.on_player_created, mod.on_player_created)

script.on_event(defines.events.on_player_display_scale_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.gui.screen[mod.button_name].location = mod.get_location(player)
end)

script.on_event(defines.events.on_player_controller_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  player.gui.screen[mod.button_name].location = mod.get_location(player)
end)

function mod.update_all_numbers()
  for _, player in pairs(game.players) do
    player.gui.screen[mod.button_name].number = mod.get_number()
  end
end

script.on_event(defines.events.on_singleplayer_init, mod.update_all_numbers)
script.on_event(defines.events.on_multiplayer_init, mod.update_all_numbers)

script.on_event(defines.events.on_player_joined_game, mod.update_all_numbers)
script.on_event(defines.events.on_player_left_game, mod.update_all_numbers)
