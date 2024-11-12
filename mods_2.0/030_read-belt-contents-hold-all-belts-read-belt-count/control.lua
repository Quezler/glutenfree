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
      anchor = {
        gui = defines.relative_gui_type.transport_belt_gui,
        position = defines.relative_gui_position.right,
      },
    }
    frame.style.top_padding = 8

    local inner = frame.add{
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      direction = "vertical",
    }

    local flow1 = inner.add{
      type = "flow",
    }

    local enabled = false

    flow1.add{
      type = "checkbox",
      style = "caption_checkbox",
      caption = {"gui-control-behavior-modes.read-belt-count"},
      state = enabled,
      enabled = enabled,
    }

    local flow2 = inner.add{
      type = "flow",
      style = "player_input_horizontal_flow"
    }
    flow2.style.top_margin = 4

    flow2.add{
      type = "label",
      caption = {"gui-control-behavior-modes-guis.control-signal"},
      enabled = enabled,
    }

    flow2.add{
      type = "choose-elem-button",
      elem_type = "signal",
      signal = {type = "virtual", name = "signal-B"},
      enabled = enabled,
    }
  end
end)

script.on_event(defines.events.on_tick, function(event)
  for _, player in ipairs(game.connected_players) do
    local opened = player.opened
    if opened and (opened.type == "transport-belt" or (opened.type == "entity-ghost" and opened.ghost_type == "transport-belt")) then
      local cb = opened.get_or_create_control_behavior() --[[@as LuaTransportBeltControlBehavior]]
      game.print(cb.read_contents and cb.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold)
    end
  end
end)
