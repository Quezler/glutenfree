local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local mod_prefix = "newsletter-for-mods-made-by-quezler-"

-- [gps=0,0,https://mods.factorio.com/mod/newsletter-for-mods-made-by-quezler] [gps=0,0,nauvis] [gps=0,0,nauviz]
script.on_event(defines.events.on_player_clicked_gps_tag, function(event)
  -- game.print("gps tag clicked!")
  -- if starts_with(event.surface, "https://mods.factorio.com/mod/") == false then return end
  local mod_url = "https://mods.factorio.com/mod/newsletter-for-mods-made-by-quezler"

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local textfield = player.gui.center[mod_prefix .. "textfield"]
  if textfield == nil then
    textfield = player.gui.center.add{
      type = "textfield",
      name = mod_prefix .. "textfield",

      text = mod_url,
    }
  else
    textfield.text = mod_url
  end

  textfield.focus()
  textfield.select_all()

  textfield.style.width = 750 -- fits "https://mods.factorio.com/mod/wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" (49 max length, w max width)
  textfield.style.horizontal_align = "center"

  player.print(string.format("[img=%s] Quezler released a new mod!", mod_prefix .. "crater"))
end)

local function close_textfield(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local textfield = player.gui.center[mod_prefix .. "textfield"]
  if textfield == nil then return end

  textfield.destroy()
end

script.on_event(mod_prefix .. "leftclick", close_textfield)

-- so that walking with WASD makes you close the textfield as well
script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element.name == mod_prefix .. "textfield" then
    close_textfield(event)
  end
end)
