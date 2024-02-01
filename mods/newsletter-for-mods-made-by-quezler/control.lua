local function starts_with(str, start)
  return str:sub(1, #start) == start
end

script.on_event(defines.events.on_player_clicked_gps_tag, function(event)
  -- game.print(string.format('x=%d, y=%d, surface=%s', event.position.x, event.position.y, event.surface))

  if starts_with(event.surface, 'https://') == false then return end

  local player = game.get_player(event.player_index)

  if game.active_mods['space-exploration'] == nil then
    player.print({"space-exploration.gps_invalid"})
  end

  local textfield = player.gui.center['newsletter-for-mods-made-by-quezler-textfield']
  if textfield == nil then
    textfield = player.gui.center.add{
      type = 'textfield',
      name = 'newsletter-for-mods-made-by-quezler-textfield',
      
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

  player.print('[img=newsletter-for-mods-made-by-quezler-crater] Quezler released a new mod!')
end)

local function close_textfield(event)
  local player = game.get_player(event.player_index)
  local textfield = player.gui.center['newsletter-for-mods-made-by-quezler-textfield']
  if textfield == nil then return end

  textfield.destroy()
end

script.on_event('newsletter-for-mods-made-by-quezler-leftclick-button', close_textfield)
