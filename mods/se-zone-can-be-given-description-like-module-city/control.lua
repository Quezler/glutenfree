local Zonelist = require('__space-exploration-scripts__.zonelist')
local print_gui = require('print_gui')

local function on_zonelist_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  log(print_gui.serpent(root))
end

local function register_events(event)
  script.on_event(remote.call("space-exploration-scripts", "on_zonelist_opened"), on_zonelist_opened)
end

script.on_init(register_events)
script.on_load(register_events)
