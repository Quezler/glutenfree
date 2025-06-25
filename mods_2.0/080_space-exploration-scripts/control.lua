local Zonelist = require("__space-exploration-scripts__.zonelist")

local on_zonelist_opened = script.generate_event_name()

remote.add_interface("space-exploration-scripts", {
  on_zonelist_opened = function() return on_zonelist_opened end, -- since 2.3.0
})

local function on_configuration_changed(event)
  storage.next_tick_events = storage.next_tick_events or {}
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function on_post_gui_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  script.raise_event(on_zonelist_opened, event)
end

local function on_tick(event)
  local next_tick_events = storage.next_tick_events
  storage.next_tick_events = {}

  for _, e in ipairs(next_tick_events) do
    if e.name == defines.events.on_gui_opened then on_post_gui_opened(e) end
  end

  if table_size(storage.next_tick_events) > 0 then return end
  script.on_event(defines.events.on_tick, nil)
end

script.on_load(function(event)
  if table_size(storage.next_tick_events) > 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  table.insert(storage.next_tick_events, event)
  script.on_event(defines.events.on_tick, on_tick)
end)
