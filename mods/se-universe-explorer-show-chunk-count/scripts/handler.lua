-- fake some of the globals so zonelist can load without errors
mod_prefix = 'se-'
core_util = require('__core__/lualib/util.lua')
Event = {}
function Event.addListener() end
Util = require('__space-exploration__.scripts.util')

local Zonelist = require('__space-exploration__.scripts.zonelist')

-- Util = nil
Event = nil
core_util = nil
mod_prefix = nil

--

local Handler = {}

function Handler.on_init()
  global.next_tick_events = {}
  
  global.chunks = {}

  for _, surface in pairs(game.surfaces) do
    global.chunks[surface.index] = 0
    for chunk in surface.get_chunks() do
      global.chunks[surface.index] = global.chunks[surface.index] + 1
    end
  end

  global.zone_index_to_surface_index = {}
end

function Handler.on_load()
  if Handler.should_on_tick() then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.should_on_tick()
  return #global.next_tick_events > 0
end

function Handler.on_tick(event)
  local next_tick_events = global.next_tick_events
  global.next_tick_events = {}
  for _, e in ipairs(next_tick_events) do
    if e.name == defines.events.on_gui_opened then Handler.on_post_gui_opened(e) end
  end
end

--

function Handler.on_gui_opened(event)
  table.insert(global.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

function Handler.on_post_gui_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = Util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  -- game.print('zonelist open :)')

  local header_frame = Util.get_gui_element(root, Zonelist.path_list_header_frame)
  header_frame['attrition'].children[1].caption = '[img=se-landfill-scaffold]'

  for _, row in pairs(scroll_pane.children) do

    -- 3 = surface name, 6 = robot inteference
    row.row_flow.children[6].caption = '-'

    if row.tags.zone_type ~= "spaceship" then

      if not global.zone_index_to_surface_index[row.tags.zone_index] then
        local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = row.tags.zone_index}) -- todo: cache this lagspike
        if zone.surface_index then
          global.zone_index_to_surface_index[row.tags.zone_index] = zone.surface_index
        else
          global.zone_index_to_surface_index[row.tags.zone_index] = 0
        end
      end

      if global.zone_index_to_surface_index[row.tags.zone_index] > 0 then
        row.row_flow.children[6].caption = global.chunks[global.zone_index_to_surface_index[row.tags.zone_index]]
      end
    end
  end

end

--

function Handler.on_surface_created(event)
  global.chunks[event.surface_index] = 0 -- assume no starting chunks exist and every single one calls on_chunk_generated

  -- since we flag non-existing surfaces as zero to prevent the remote.call spam we'd have to clear it on new surfaces too
  global.zone_index_to_surface_index = {}
end

function Handler.on_surface_deleted(event)
  global.chunks[event.surface_index] = nil

  -- surface indexes do not seem to shift to fill gaps, but this forgets the cached deleted surface too
  global.zone_index_to_surface_index = {}
end

function Handler.on_chunk_generated(event)
  global.chunks[event.surface.index] = global.chunks[event.surface.index] + 1
end

function Handler.on_chunk_deleted(event)
  global.chunks[event.surface.index] = global.chunks[event.surface.index] - #event.positions
end

--

return Handler
