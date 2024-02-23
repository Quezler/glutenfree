local util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

local textfield_name = 'se-zone-rename'
local print_gui = require('print_gui')

local function update_zonelist_for_player(player, root)
  -- log(print_gui.serpent(root))
  
  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  local forcedata = global.forcedata[player.force.name] or {}

  for _, row in pairs(scroll_pane.children) do
    if row.tags.zone_type ~= 'spaceship' then
      local name_cell = row.row_flow.children[3]

      local renamed = forcedata[row.tags.zone_index]
      local caption = name_cell.caption
      if type(caption) == "string" then 
        -- log(caption)
        if renamed == nil then renamed = caption caption = '' end
        caption = {"space-exploration.zonelist-renamed-zone", renamed, caption}
      else
        -- assert(caption[1] == 'space-exploration.zonelist-renamed-zone')
        if renamed ~= nil and caption[3] == '' then caption[3] = caption[2] end

        if renamed == nil and caption[3] ~= '' then renamed = caption[3] caption[3] = '' end
        if renamed == nil and caption[3] == '' then renamed = caption[2] end

        caption[2] = renamed
      end
      name_cell.caption = caption
      log(serpent.line(caption))
    end
  end

  local parent = util.get_gui_element(root, Zonelist.path_zone_data_flow)
  if not parent then return end

  local container = parent[Zonelist.name_zone_data_container_frame]
  local content = container[Zonelist.name_zone_data_content_scroll_pane]

  local button_flow = content.parent.parent[Zonelist.name_zone_data_bottom_button_flow]
  local view_button = button_flow[Zonelist.name_zone_data_view_surface_button]
  local zone_index = view_button.tags.zone_index

  if view_button.tags.zone_type == "spaceship" then
    -- todo: hide/disable name box
    return
  end

  local rename = content[textfield_name]
  if rename == nil then
    content.add{
      type = 'textfield',
      name = textfield_name,
      index = 1,
      lose_focus_on_confirm = true,
      clear_and_focus_on_right_click = true,
    }
    rename = content[textfield_name]
    rename.style.width = 256
  end

  assert(view_button.tags.zone_type ~= 'spaceship')
  rename.tags = {action = 'rename-zone', zone_index = zone_index}
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

local function on_init(event)
  global.forcedata = {}

  register_events(event)
end

script.on_init(on_init)
script.on_load(register_events)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  update_zonelist_for_player(player, root)
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name ~= textfield_name then return end

  local player = game.get_player(event.player_index)
  if global.forcedata[player.force.name] == nil then global.forcedata[player.force.name] = {} end

  if event.element.text == "" then
    global.forcedata[player.force.name][event.element.tags.zone_index] = nil
  else
    global.forcedata[player.force.name][event.element.tags.zone_index] = event.element.text
  end

  update_zonelist_for_player(player, Zonelist.get(player))
end)
