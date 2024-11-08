local mod_prefix = 'csrsbsy-'

script.on_init(function()

end)

script.on_nth_tick(60, function(event)
  local player = game.players["Quezler"]

  local textfield = player.gui.center[mod_prefix .. 'textfield']
  if textfield == nil then
    textfield = player.gui.center.add{
      type = 'textfield',
      name = mod_prefix .. 'textfield',

      text = 'hello',
    }
  else
    textfield.text = 'world'
  end
end)
