local util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

--

local Handler = {}

function Handler.on_init()
  global.next_tick_events = {}
  
  -- global.chunks = {} -- todo: delete in an on_configuration_changed

  global.zone_index_to_surface_index = {}

  global.surface_index_to_captions_array = {}
end

function Handler.on_configuration_changed()
  global.surface_index_to_captions_array = {}
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

  if Handler.should_on_tick() then return end
  script.on_event(defines.events.on_tick, nil)
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

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  -- game.print('zonelist open :)')

  local chunks = remote.call("chunk-count", "get")

  local header_frame = util.get_gui_element(root, Zonelist.path_list_header_frame)
  header_frame['attrition'].children[1].enabled = false -- disable sorting until we manually resort someday after a Zonelist._sorting_functions call
  header_frame['attrition'].children[1].caption = '[img=se-landfill-scaffold]'

  for _, row in pairs(scroll_pane.children) do

    -- 3 = surface name, 6 = robot inteference
    local chunk_cell = row.row_flow.children[6]
    chunk_cell.caption = '-'

    if row.tags.zone_type ~= "spaceship" then

      if not global.zone_index_to_surface_index[row.tags.zone_index] then
        local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = row.tags.zone_index}) -- todo: cache this lagspike
        if zone.surface_index then
          global.zone_index_to_surface_index[row.tags.zone_index] = zone.surface_index
        else
          global.zone_index_to_surface_index[row.tags.zone_index] = 0
        end
      end

      local surface_index = global.zone_index_to_surface_index[row.tags.zone_index]
      if surface_index > 0 then
        chunk_cell.caption = chunks[surface_index]
        if global.surface_index_to_captions_array[surface_index] == nil then
          global.surface_index_to_captions_array[surface_index] = {chunk_cell}
        else
          table.insert(global.surface_index_to_captions_array, chunk_cell)
        end
      end
    end
  end

end

--

function Handler.on_surface_created(event)
  -- since we flag non-existing surfaces as zero to prevent the remote.call spam we'd have to clear it on new surfaces too
  global.zone_index_to_surface_index = {}
end

function Handler.on_surface_deleted(event)
  -- surface indexes do not seem to shift to fill gaps, but this forgets the cached deleted surface too
  global.zone_index_to_surface_index = {}
end

function Handler.on_chunk_generated(event)
  local array = global.surface_index_to_captions_array[event.surface.index]
  if not array then return end

  for i = #array, 1, -1 do
    local chunk_cell = array[i]
    if chunk_cell.valid then
      chunk_cell.caption = tonumber(chunk_cell.caption) + 1
    else
      array[i] = nil
    end
  end

  if #array == 0 then
    global.surface_index_to_captions_array[event.surface.index] = nil
  end
end

--

return Handler
