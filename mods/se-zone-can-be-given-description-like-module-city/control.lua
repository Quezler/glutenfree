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
