local Planner = require('scripts.planner')

--

local function init()
  Planner.init()
end

local function load()
  --
end

script.on_init(function()
  init()
  load()
end)

script.on_load(function()
  load()
end)

--

script.on_event(defines.events.on_player_selected_area, function(event)
  -- game.print('on_player_selected_area')
  Planner.on_player_selected_area(event)
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
  -- game.print('on_player_alt_selected_area')
  Planner.on_player_alt_selected_area(event)
end)

script.on_event(defines.events.on_entity_destroyed, Planner.on_entity_destroyed)
script.on_event(defines.events.on_cancelled_deconstruction, Planner.on_cancelled_deconstruction)
