local util = require("__space-exploration-scripts__.util")
local Zonelist = require("__space-exploration-scripts__.zonelist")

--

local Handler = {}

function Handler.on_init()
  storage.zone_index_to_surface_index = {}
  storage.surface_index_to_captions_array = {}

  script.on_event(remote.call("space-exploration-scripts", "on_zonelist_opened"), Handler.on_zonelist_opened)
end

function Handler.on_configuration_changed()
  storage.surface_index_to_captions_array = {}
end

function Handler.on_load()
  script.on_event(remote.call("space-exploration-scripts", "on_zonelist_opened"), Handler.on_zonelist_opened)
end

--

function Handler.on_zonelist_opened(event)
  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  -- game.print("zonelist open :)")

  local chunks = remote.call("chunk-count", "get")

  local header_frame = util.get_gui_element(root, Zonelist.path_list_header_frame)
  header_frame["attrition"].children[1].enabled = false -- disable sorting until we manually resort someday after a Zonelist._sorting_functions call
  header_frame["attrition"].children[1].caption = "[img=se-landfill-scaffold]"

  for _, row in pairs(scroll_pane.children) do

    -- 3 = surface name, 6 = robot inteference
    local chunk_cell = row.row_flow.children[6]
    chunk_cell.caption = "-"

    if row.tags.zone_type ~= "spaceship" then

      if not storage.zone_index_to_surface_index[row.tags.zone_index] then
        local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = row.tags.zone_index}) -- todo: cache this lagspike
        if zone.surface_index then
          storage.zone_index_to_surface_index[row.tags.zone_index] = zone.surface_index
        else
          storage.zone_index_to_surface_index[row.tags.zone_index] = 0
        end
      end

      local surface_index = storage.zone_index_to_surface_index[row.tags.zone_index]
      if surface_index > 0 then
        chunk_cell.caption = chunks[surface_index]
        if storage.surface_index_to_captions_array[surface_index] == nil then
          storage.surface_index_to_captions_array[surface_index] = {chunk_cell}
        else
          table.insert(storage.surface_index_to_captions_array[surface_index], chunk_cell)
        end
      end
    end
  end

end

--

function update_captions_for_surface(surface_index, override)
  local array = storage.surface_index_to_captions_array[surface_index]
  if not array then return end

  for i = #array, 1, -1 do
    local chunk_cell = array[i]
    if chunk_cell.valid then
      chunk_cell.caption = override and override or ((tonumber(chunk_cell.caption) or 0) + 1)
    else
      table.remove(array, i)
    end
  end

  if #array == 0 then
    storage.surface_index_to_captions_array[surface_index] = nil
  end
end

function Handler.on_surface_created(event)
  -- since we flag non-existing surfaces as zero to prevent the remote.call spam we"d have to clear it on new surfaces too
  storage.zone_index_to_surface_index = {}
  -- for _, player in pairs(game.players) do
  --   Handler.on_zonelist_opened({player_index = player.index})
  -- end
  -- local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  -- log(serpent.line(zone))
  -- log(event.surface_index)
  -- if zone then
  --   storage.zone_index_to_surface_index[zone.index] = zone.surface_index
  --   update_captions_for_surface(event.surface_index)
  -- end
end

function Handler.on_surface_deleted(event)
  -- surface indexes do not seem to shift to fill gaps, but this forgets the cached deleted surface too
  storage.zone_index_to_surface_index = {}
  update_captions_for_surface(event.surface_index, '-')
end

function Handler.on_chunk_generated(event)
  update_captions_for_surface(event.surface.index)
end

function Handler.on_chunk_deleted(event)
  update_captions_for_surface(event.surface_index, remote.call("chunk-count", "get", {surface_index = event.surface_index}))
end

--

return Handler
