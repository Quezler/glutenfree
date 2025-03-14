require("util")
require("shared")
require("scripts.factoryplanner")
require("scripts.luagui-pretty-print")

script.on_event(defines.events.on_gui_opened, function(event)
  Factoryplanner.on_gui_opened(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == mod_prefix .. "summon-magic-hut" then
    Factoryplanner.on_gui_click(event)
  end

  log(LuaGuiPrettyPrint.path_to_element(event.element))
end)
