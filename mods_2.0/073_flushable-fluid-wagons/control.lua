require("util")

script.on_init(function()
  storage.playerdata = {}
end)

script.on_configuration_changed(function()
  --
end)

local gui_frame_name = "flushable-fluid-wagons--frame"
local gui_flush_name = "flushable-fluid-wagons--flush"

local localised_name_for_fluid = {}
for _, prototype in pairs(prototypes.fluid) do
  localised_name_for_fluid[prototype.name] = prototype.localised_name
end

local function update_gui(playerdata)
  local fluid = playerdata.entity.get_fluid(1)
  local has_fluid = fluid ~= nil

  playerdata.contents.visible = has_fluid
  playerdata.table.visible = has_fluid
  if not has_fluid then return end

  playerdata.button.sprite = "fluid/" .. fluid.name
  playerdata.button.elem_tooltip = {type = "fluid", name = fluid.name}

  playerdata.label.caption = util.format_number(fluid.amount, true)
  playerdata.label.tooltip = string.format("%.4f", fluid.amount)
  playerdata.trash.tooltip = {"gui-pipe.flush-this", localised_name_for_fluid[fluid.name]}
end

local function open_gui(playerdata)
  local player = playerdata.player
  local entity = playerdata.entity

  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = entity.prototype.localised_name,
    tags = {
      unit_number = entity.unit_number,
    }
  }
  frame.style.minimal_width = 448

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  local entity_preview_frame = inner.add{
    type = "frame",
    style = "deep_frame_in_shallow_frame",
  }

  local entity_preview = entity_preview_frame.add{
    type = "entity-preview",
    style = "wide_entity_button",
  }
  entity_preview.entity = entity

  local contents = inner.add{
    type = "label",
    caption = {"gui-pipe.this-contents", entity.localised_name},
  }
  contents.style.font = "default-semibold"
  contents.style.top_margin = 5
  contents.style.bottom_margin = 5

  local gui_table = inner.add{
    type = "table",
    column_count = 4,
  }

  local sprite_button = gui_table.add{
    type = "sprite-button",
    sprite = "fluid/fluid-unknown",
    style = "transparent_slot",
    -- elem_tooltip,
  }

  local label = gui_table.add{
    type = "label",
    -- caption,
    -- tooltip,
  }

  local pusher = gui_table.add{
    type = "empty-widget",
  }
  pusher.style.horizontally_stretchable = true

  local trash = gui_table.add{
    name = gui_flush_name,
    type = "sprite-button",
    sprite = "utility/trash",
    style = "tool_button_flush_fluid",
    -- tooltip,
  }

  player.opened = frame
  frame.force_auto_center()

  playerdata.contents = contents
  playerdata.table = gui_table
  playerdata.button = sprite_button
  playerdata.label = label
  playerdata.trash = trash
end

local function on_tick_playerdata(playerdata)
  local player = playerdata.player

  if not player.valid then return false end
  if not player.connected then return false end

  if not playerdata.entity.valid then return false end
  if not playerdata.opened then
    open_gui(playerdata)
    playerdata.opened = true
  end

  if not player.gui.screen[gui_frame_name] then return false end
  update_gui(playerdata)
end

local function on_tick(event)
  for player_index, playerdata in pairs(storage.playerdata) do
    if on_tick_playerdata(playerdata) == false then
      storage.playerdata[player_index] = nil
    end
  end

  if not next(storage.playerdata) then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if next(storage.playerdata) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

---@param event EventData.CustomInputEvent
script.on_event("open-fluid-wagon", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local entity = player.selected
  if entity == nil or entity.type ~= "fluid-wagon" then return end

  local fluid = entity.get_fluid(1)
  if fluid == nil then return end -- empty fluid wagon (to allow access to equipment)

  storage.playerdata[player.index] = {
    player = player,
    entity = entity,
    opened = false,
  }

  script.on_event(defines.events.on_tick, on_tick)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local element = event.element
  if element and element.name == gui_frame_name then
    element.destroy()
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.name == gui_flush_name then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local playerdata = storage.playerdata[player.index]
    playerdata.entity.clear_fluid_inside()
  end
end)
