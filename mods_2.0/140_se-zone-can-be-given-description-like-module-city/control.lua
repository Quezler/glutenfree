local util = require("__space-exploration-scripts__.util")
local Zone = require("__space-exploration-scripts__.zone")
local Zonelist = require("__space-exploration-scripts__.zonelist")
local GuiCommon = require("__space-exploration-scripts__.gui-common")

local textfield_name = "se-zone-rename"
-- local print_gui = require("print_gui")

local mod = {}

local function update_zonelist_for_player(player, root)
  -- log(print_gui.serpent(root))

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  local forcedata = storage.forcedata[player.force.name] or {}

  for _, row in pairs(scroll_pane.children) do
    if row.tags.zone_type ~= "spaceship" then
      local name_cell = row.row_flow.children[3]

      local renamed = forcedata[row.tags.zone_index]
      local caption = name_cell.caption
      if type(caption) == "string" then
        caption = {"space-exploration.zonelist-renamed-zone", caption, renamed}
      else
        assert(caption[1] == "space-exploration.zonelist-renamed-zone")
        caption[3] = renamed and (" " .. renamed) or ""
      end
      name_cell.caption = caption
    end
  end

  local parent = util.get_gui_element(root, Zonelist.path_zone_data_flow)
  if not parent then return end

  local container = parent[Zonelist.name_zone_data_container_frame]
  local content = container[Zonelist.name_zone_data_content_scroll_pane]

  local button_flow = content.parent.parent[Zonelist.name_zone_data_bottom_button_flow]
  local view_button = button_flow[Zonelist.name_zone_data_view_surface_button]
  local zone_index = view_button.tags.zone_index

  local rename = content[textfield_name]
  if rename == nil then
    local name_horizontal_flow = content.add{
      type = "flow",
      name = textfield_name,
      direction = "horizontal",
      index = 1,
    }
    name_horizontal_flow.add{
      type = "textfield",
      name = GuiCommon.rename_textfield_name,
      lose_focus_on_confirm = true,
      style = "se_textfield_maximum_stretchable",
    }
    name_horizontal_flow.add{
      type = "choose-elem-button",
      elem_type = "signal",
      signal = {
        type = "virtual",
        name = (mod_prefix or "se-") .. "select-icon"
      },
      name = GuiCommon.icon_selector_name,
      style = "se_icon_selector_button",
    }
    rename = content[textfield_name]
  end

  rename[GuiCommon.rename_textfield_name].enabled = view_button.tags.zone_type ~= "spaceship"
  rename[GuiCommon.icon_selector_name].enabled = rename[GuiCommon.rename_textfield_name].enabled

  rename[GuiCommon.rename_textfield_name].tags = {action = "rename-zone", zone_index = zone_index, zone_type = view_button.tags.zone_type}
  rename[GuiCommon.rename_textfield_name].text = forcedata[zone_index] or ""

  storage.action_zone_link_triggers[player.index] = {
    player = player,
    element = content["details"].children[1],
  }
  script.on_event(defines.events.on_tick, mod.on_tick)
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
  storage.forcedata = {}

  -- in a zone's sidebar you can click on parents/spaceships to quickly go there,
  -- but since those delete the element other mods cannot receive their click event.
  storage.action_zone_link_triggers = {}

  register_events(event)

  for _, surface in pairs(game.surfaces) do
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
    if zone then
      surface.localised_name = {"space-exploration.zonelist-renamed-zone", Zone._get_rich_text_name(zone), ""}
    end
  end
end

script.on_init(on_init)
script.on_load(mod.on_load)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == GuiCommon.icon_selector_name then return end -- it would erase any typed-yet-not-confirmed stuff when picking an icon

  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  update_zonelist_for_player(player, root)
end)

script.on_event(defines.events.on_gui_confirmed, function(event)
  if event.element.name ~= GuiCommon.rename_textfield_name then return end

  -- we require the zone type to be present, as well as not a spaceship, to ensure forcedata does not get tainted.
  assert(event.element.tags.zone_type)
  assert(event.element.tags.zone_type ~= "spaceship")

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if storage.forcedata[player.force.name] == nil then storage.forcedata[player.force.name] = {} end

  if event.element.text == "" then
    storage.forcedata[player.force.name][event.element.tags.zone_index] = nil
  else
    storage.forcedata[player.force.name][event.element.tags.zone_index] = event.element.text
  end

  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.element.tags.zone_index})
  if zone.surface_index then
    local surface = game.get_surface(zone.surface_index) --[[@as LuaSurface]]
    surface.localised_name = {"space-exploration.zonelist-renamed-zone", Zone._get_rich_text_name(zone), event.element.text == "" and "" or (" " .. event.element.text)}
  end

  update_zonelist_for_player(player, Zonelist.get(player))
end)

function mod.on_tick(event)
  for _, action_zone_link_trigger in pairs(storage.action_zone_link_triggers) do
    if action_zone_link_trigger.element.valid == false then
      storage.action_zone_link_triggers[_] = nil

      local root = Zonelist.get(action_zone_link_trigger.player)
      if root then
        update_zonelist_for_player(action_zone_link_trigger.player, root)
      end
    end
  end

  -- effectively when no-one has the universe explorer open
  if table_size(storage.action_zone_link_triggers) == 0 then
    -- game.print("triggers emptied")
    script.on_event(defines.events.on_tick, nil)
  end
end

function mod.on_load(event)
  if table_size(storage.action_zone_link_triggers) > 0 then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end

  register_events(event)
end
