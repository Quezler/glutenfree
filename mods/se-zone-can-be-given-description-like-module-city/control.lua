local util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

local print_gui = require('print_gui')

local function update_zonelist_for_player(player, root)
  log(print_gui.serpent(root))
  
  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  for _, row in pairs(scroll_pane.children) do
    local name_cell = row.row_flow.children[3]

    name_cell.caption = string.format('Module City [font=default-smaller]%s[/font]', name_cell.caption)
  end

  local zone_index = nil
  if not zone_index then
    local parent = util.get_gui_element(root, Zonelist.path_zone_data_flow)
    if not parent then return end

    local container = parent[Zonelist.name_zone_data_container_frame]
    local content = container[Zonelist.name_zone_data_content_scroll_pane]

    local button_flow = content.parent.parent[Zonelist.name_zone_data_bottom_button_flow]
    local view_button = button_flow[Zonelist.name_zone_data_view_surface_button]
    zone_index = view_button.tags.zone_index

    if view_button.tags.zone_type == "spaceship" then
      -- coremining_header.visible = false
      -- coremining.visible = false
      return
    end
  end

  game.print(zone_index)
end

local function on_zonelist_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  update_zonelist_for_player(player, root)
end

local function register_events(event)
  script.on_event(remote.call("space-exploration-scripts", "on_zonelist_opened"), on_zonelist_opened)
end

script.on_init(register_events)
script.on_load(register_events)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  update_zonelist_for_player(player, root)

  -- local parent = Util.get_gui_element(root, Zonelist.path_zone_data_flow)
  -- if not parent then return end

  -- local container = parent[Zonelist.name_zone_data_container_frame]
  -- local content = container[Zonelist.name_zone_data_content_scroll_pane]
end)
