local pollution_tool = require("scripts.pollution-tool")

--

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item == "pollution-tool" then
    pollution_tool.on_player_selected_area(event)
  end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
  if event.item == "pollution-tool" then
    pollution_tool.on_player_selected_area(event)
  end
end)
