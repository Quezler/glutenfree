local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local mod_prefix = 'newsletter-for-mods-made-by-quezler-'

script.on_event(defines.events.on_player_clicked_gps_tag, function(event)
  if starts_with(event.surface, 'https://mods.factorio.com/mod/') == false then return end

  local player = game.get_player(event.player_index)

  if game.active_mods['space-exploration'] == nil then
    player.print({"space-exploration.gps_invalid"})
  end

  local textfield = player.gui.center[mod_prefix .. 'textfield']
  if textfield == nil then
    textfield = player.gui.center.add{
      type = 'textfield',
      name = mod_prefix .. 'textfield',

      text = event.surface,
    }
  else
    textfield.text = event.surface
  end

  textfield.focus()
  textfield.select_all()
  -- textfield.read_only = true

  textfield.style.width = 750 -- fits "https://mods.factorio.com/mod/wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" (49 max length, w max width)
  textfield.style.horizontal_align = "center"

  player.print(string.format('[img=%s] Quezler released a new mod!', mod_prefix .. 'crater'))
end)

local function close_textfield(event)
  local player = game.get_player(event.player_index)
  local textfield = player.gui.center[mod_prefix .. 'textfield']
  if textfield == nil then return end

  textfield.destroy()
end

script.on_event(mod_prefix .. 'leftclick-button', close_textfield)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element.name == mod_prefix .. 'textfield' then
    close_textfield(event)
  end
end)
