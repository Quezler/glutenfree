local util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

Zonelist.color_priority_frozen = {51, 153, 255}

--

local Handler = {}

function Handler.on_init()
  global.next_tick_events = {}
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

  local zonelist_scroll = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not zonelist_scroll then return end

  local header_frame = util.get_gui_element(root, Zonelist.path_list_header_frame)

  -- Whilst `header_frame['priority'].children[1].state` holds the priority, several sortings can be active,
  -- and i cannot be bothered to track them by mimicking the `playerdata.zonelist_sort_criteria` table.
  -- So instead i'll just **force sort** by priority when you open the gui, you can re-sort then.
  -- Or actually, lets just see if the current list is sorted by priority, not that hard.

  -- return if the sorting column doesn't even have an up or down carret at all
  if (header_frame['priority'].children[1].style.name == "se_zonelist_sort_checkbox_inactive") then return end

  local high_to_low = not header_frame['priority'].children[1].state -- top to bottom

  -- return if the priority isn't in either order (and thus priority isn't the primary sorting column)
  if high_to_low then
    local lowest = math.huge
    for _, row in pairs(zonelist_scroll.children) do
      local priority = tonumber(row.row_flow.children[11].caption)
      if priority > lowest then return end
      lowest = priority
    end
  else
    local highest = -math.huge
    for _, row in pairs(zonelist_scroll.children) do
      local priority = tonumber(row.row_flow.children[11].caption)
      if priority < highest then return end
      highest = priority
    end
  end

  -- hide the up & down caret for all but the priority column (until the user sorts a column)
  for i = 1, 10 do
    header_frame.children[i].children[1].style = "se_zonelist_sort_checkbox_inactive"
  end

  local sorted = {}
  local sorter = function(a, b) return a.spaceship_id < b.spaceship_id end

  for _, row in pairs(zonelist_scroll.children) do
    -- print(row.row_flow.children[11].caption)
    -- print(row.row_flow.children[11].style.font_color)
    if row.tags.zone_type == "spaceship" then
      row.row_flow.children[11].style.font_color = Zonelist.color_priority_frozen

      -- Canary prospector [font=default-small][1][/font]
      local spaceship_id = tonumber(string.match(row.row_flow.children[3].caption, "%[(%d+)%]%[/font%]%s*$"))
      -- print(row.row_flow.children[3].caption)
      -- print(spaceship_id)
      table.insert(sorted, {
        row = row,
        -- old_index = _,
        spaceship_id = spaceship_id,
      })
    end
  end

  table.sort(sorted, sorter)

  -- put everything else as-is under the spaceships
  for _, row in pairs(zonelist_scroll.children) do
    if row.tags.zone_type ~= "spaceship" then
      table.insert(sorted, {
        row = row,
        -- old_index = _,
      })
    end
  end

  for new_index, struct in pairs(sorted) do
    local old_index = struct.row.get_index_in_parent()
    if new_index ~= old_index then zonelist_scroll.swap_children(new_index, old_index) end
  end
end

--

script.on_init(Handler.on_init)
script.on_load(Handler.on_load)

script.on_event(defines.events.on_gui_opened, Handler.on_gui_opened)
