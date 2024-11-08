local mod_prefix = 'csrsbsy-'

script.on_init(function()

end)

script.on_nth_tick(60, function(event)
  local player = game.players["Quezler"]

  local textfield = player.gui.center[mod_prefix .. 'textfield']
  if textfield == nil then
    textfield = player.gui.center.add{
      -- type = 'empty-widget',
      type = 'frame',
      name = mod_prefix .. 'textfield',
    }
  else
  end

  textfield.style.width = 100
  textfield.style.height = 200
  textfield.style.bottom_margin = 150
  textfield.raise_hover_events = true
end)

script.on_event(defines.events.on_gui_hover, function(event)
  game.print("on_gui_hover")
end)

script.on_event(defines.events.on_gui_leave, function(event)
  game.print("on_gui_leave")
end)

script.on_event("csrsbsy-zoom-in", function(event)
  game.print(string.format("zoomed in @ %d", event.tick))
end)

script.on_event("csrsbsy-zoom-out", function(event)
  game.print(string.format("zoomed out @ %d", event.tick))
end)
