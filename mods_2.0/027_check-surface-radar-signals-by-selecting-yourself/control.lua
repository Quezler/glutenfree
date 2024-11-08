local mod_prefix = 'csrsbsy-'

script.on_init(function()

end)

-- script.on_nth_tick(60, function(event)
--   local player = game.players["Quezler"]

--   local textfield = player.gui.center[mod_prefix .. 'textfield']
--   if textfield == nil then
--     textfield = player.gui.center.add{
--       -- type = 'empty-widget',
--       type = 'frame',
--       name = mod_prefix .. 'textfield',
--     }
--   else
--   end

--   textfield.style.width = 100
--   textfield.style.height = 200
--   textfield.style.bottom_margin = 150
--   textfield.raise_hover_events = true
--   textfield.game_controller_interaction = defines.game_controller_interaction.never
--   textfield.ignored_by_interaction = true
-- end)

-- running this does cause it to fire the event, neat
-- /c game.player.gui.center["csrsbsy-textfield"].ignored_by_interaction = false

-- script.on_event(defines.events.on_gui_hover, function(event)
--   game.print("on_gui_hover")
-- end)

-- script.on_event(defines.events.on_gui_leave, function(event)
--   game.print("on_gui_leave")
-- end)

-- script.on_event(defines.events.on_player_changed_position, function(event)
--   game.print(event.tick)
-- end)

-- script.on_event(defines.events.on_tick, function(event)
--   local player = game.get_player("Quezler") --[[@as LuaPlayer]]
-- end)
