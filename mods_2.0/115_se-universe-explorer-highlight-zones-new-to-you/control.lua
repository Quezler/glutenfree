local mod = {}

script.on_init(function(event)
  storage.version = 2

  storage.player_index_to_selected_zones_map = {}

  mod.register_events()
end)

local util = require("__space-exploration-scripts__.util")
local Zonelist = require("__space-exploration-scripts__.zonelist")

local function on_zonelist_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  for _, row in pairs(scroll_pane.children) do
    local tags = row.tags
    if not storage.player_index_to_selected_zones_map[event.player_index]
    or not storage.player_index_to_selected_zones_map[event.player_index][tags.zone_type]
    or not storage.player_index_to_selected_zones_map[event.player_index][tags.zone_type][tags.zone_index] then
      row.row_flow.children[2].add{ -- Zone icon
        type = "sprite",
        sprite = "utility/notification",
        style = "se_zonelist_row_cell_type_notification"
      }
    end
  end

end

function mod.register_events(event)
  script.on_event(remote.call("space-exploration-scripts", "on_zonelist_opened"), on_zonelist_opened)
end

script.on_load(mod.register_events)

local function mark_as_seen(player_index, tags)
  storage.player_index_to_selected_zones_map[player_index]                                  = storage.player_index_to_selected_zones_map[player_index] or {}
  storage.player_index_to_selected_zones_map[player_index][tags.zone_type]                  = storage.player_index_to_selected_zones_map[player_index][tags.zone_type] or {}
  storage.player_index_to_selected_zones_map[player_index][tags.zone_type][tags.zone_index] = true
end

script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.tags and event.element.tags.action == Zonelist.action_zone_row_button then
  --game.print("selected zone " .. event.element.tags.zone_index)
    mark_as_seen(event.player_index, event.element.tags)

    local notification = event.element.row_flow.children[2].children[1]
    if notification then notification.destroy() end
  end
end)

script.on_configuration_changed(function(event)
  assert(storage.version >= 2)
  -- storage.version = storage.version or 0

  -- if storage.version == 0 then
  --   local zones = remote.call("space-exploration", "get_zone_index", {}) -- does not return `zone.type == spaceship`'s

  --   local zone_by_index = {}
  --   for _, zone in ipairs(zones) do
  --     zone_by_index[zone.index] = zone
  --   end

  --   local player_index_to_selected_zones_map = storage.player_index_to_selected_zones_map
  --   storage.player_index_to_selected_zones_map = {}

  --   for player_index, map in pairs(player_index_to_selected_zones_map) do
  --     local visible_zones = remote.call("space-exploration", "get_known_zones", {force_name = game.get_player(player_index).force.name})

  --     local visible_zone_by_index = {}
  --     for _, zone in ipairs(zones) do
  --       visible_zone_by_index[zone.index] = zone
  --     end

  --     for zone_index, _ in pairs(map) do
  --       local zone = zone_by_index[zone_index]
  --       if zone and visible_zone_by_index[zone_index] then
  --         mark_as_seen(player_index, {zone_type = zone.type, zone_index = zone.index})
  --       end
  --     end
  --   end

  --   storage.version = 1
  -- end

  -- if storage.version == 1 then
  --   storage.next_tick_events = nil
  --   storage.version = 2
  -- end
end)
