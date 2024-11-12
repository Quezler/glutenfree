local frame_name = "rbchabrbc-frame"

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.type == "transport-belt" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    local frame = player.gui.relative[frame_name]
    if frame then frame.destroy() end

    frame = player.gui.relative.add{
      type = "frame",
      name = frame_name,
      caption = { "gui-control-behavior-modes.read-belt-count" },
      anchor = {
        gui = defines.relative_gui_type.transport_belt_gui,
        position = defines.relative_gui_position.right,
      },
    }

    local inner = frame.add{
      type = "frame",
      style = "inside_shallow_frame_with_padding",
    }

    -- inner.style.vertical_align = "center"

    local flow = inner.add{
      type = "flow",
      style = "player_input_horizontal_flow"
    }

    flow.add{
      type = "label",
      caption = {"gui-control-behavior-modes-guis.control-signal"}
    }

    flow.add{
      type = "choose-elem-button",
      elem_type = "signal",
      signal = {type = "virtual", name = "signal-B"},
    }
  end
end)