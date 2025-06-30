require("namespace")

script.on_init(function()
  log(serpent.block(prototypes.mod_data[mod_prefix .. "original-technology-effects"].data))
end)

local gui_frame_name = mod_prefix .. "frame"

local function open_gui(player)
  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = {"mod-name." .. mod_name},
  }

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  player.opened = frame
  frame.force_auto_center()
end

commands.add_command(mod_name, nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  open_gui(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == gui_frame_name then
    event.element.destroy()
  end
end)
