script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if event.element.name == "change_channel_dropdown" then
    local channel = event.element.items[event.element.selected_index]
    local unit_number = tonumber(event.element.parent.parent.parent.children[1].children[1].name)
    remote.call("aai-signal-transmission-luarendered-channel-label", "update_text", unit_number, channel)
  end
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name == "write-channel" then -- enter pressed
    local channel = event.element.text
    local unit_number = tonumber(event.element.parent.parent.parent.parent.children[1].children[1].name)
    remote.call("aai-signal-transmission-luarendered-channel-label", "update_text", unit_number, channel)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "change-channel-confirm" then -- apply clicked
    local channel = event.element.parent.children[1].text
    local unit_number = tonumber(event.element.parent.parent.parent.parent.children[1].children[1].name)
    remote.call("aai-signal-transmission-luarendered-channel-label", "update_text", unit_number, channel)
  end
end)
