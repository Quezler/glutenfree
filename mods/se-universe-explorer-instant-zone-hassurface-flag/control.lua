script.on_init(function(event)
  global.next_tick_events = {}

  global.zone_index_to_flags_cells = {}
end)

local util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

local function on_post_gui_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  for _, row in pairs(scroll_pane.children) do

    -- 3 = surface name, 6 = robot inteference
    local flags_cell = row.row_flow.children[9]

    global.zone_index_to_flags_cells[row.tags.zone_index] = global.zone_index_to_flags_cells[row.tags.zone_index] or {}
    global.zone_index_to_flags_cells[row.tags.zone_index][player.index] = flags_cell

  end

end

local function on_tick(event)
  local next_tick_events = global.next_tick_events
  global.next_tick_events = {}
  
  for _, e in ipairs(next_tick_events) do
    if e.name == defines.events.on_gui_opened then on_post_gui_opened(e) end
  end

  if #global.next_tick_events > 0 then return end
  script.on_event(defines.events.on_tick, nil)
end

script.on_load(function(event)
  if #global.next_tick_events > 0 then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  table.insert(global.next_tick_events, event)
  script.on_event(defines.events.on_tick, on_tick)
end)

-- script.on_event(defines.events.on_gui_click, function(event)
--   if event.element and event.element.tags and event.element.tags.action == Zonelist.action_zone_row_button then
--   --game.print('selected zone ' .. event.element.tags.zone_index)
--     global.player_index_to_selected_zones_map[event.player_index] = global.player_index_to_selected_zones_map[event.player_index] or {}
--     global.player_index_to_selected_zones_map[event.player_index][event.element.tags.zone_index] = true

--     local notification = event.element.row_flow.children[2].children[1]
--     if notification then notification.destroy() end
--   end
-- end)

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]
  game.print(surface.index)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
  game.print(serpent.line( zone == nil ))
  if not zone then return end

  for zone_index, flags_cells in pairs(global.zone_index_to_flags_cells) do
    for player_index, flags_cells in pairs(flags_cells) do

    end
  end
end)
