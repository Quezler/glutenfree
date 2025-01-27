local mod_name = "quality-upgrade-planner"

local shared = require("shared")
local Modes = require("scripts.modes")

local function on_player_created(event)
  storage.playerdata[event.player_index] = {
    player = game.get_player(event.player_index),
    switch_states = {},
  }
end

local function on_player_removed(event)
  storage.playerdata[event.player_index] = nil
end

script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_removed, on_player_removed)

local function on_configuration_changed()
  if storage.inventory then -- 1.0.1 - 1.0.8
    storage.inventory.destroy()
    storage.inventory = nil
  end

  storage.playerdata = {} -- todo: keep between versions?
  for _, player in pairs(game.players) do
    on_player_created({player_index = player.index})
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local next_quality = {}
local previous_quality = {}

-- does not support two qualities having the same next
for _, quality in pairs(prototypes.quality) do
  if quality.next then
    next_quality[quality.name] = quality.next
    previous_quality[quality.next.name] = quality
  end
end

local is_quality_upgrade_planner_item = {["quality-upgrade-planner"] = true}

local mod_prefix = "quality-upgrade-planner--"

local function set_stack_to_quality_upgrade_planner(cursor_stack, quality)
  cursor_stack.set_stack({name = "quality-upgrade-planner", quality = quality.name})
  cursor_stack.label = string.upper(string.sub(quality.name, 1, 1)) .. string.sub(quality.name, 2)
  cursor_stack.label_color = quality.color
end

local function cycle_quality(event, up_or_down)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack and cursor_stack.valid_for_read and is_quality_upgrade_planner_item[cursor_stack.name] then
    local quality = (up_or_down == "up" and next_quality or previous_quality)[cursor_stack.quality.name]
    if quality then
      set_stack_to_quality_upgrade_planner(cursor_stack, quality)
    end
  end
end

script.on_event(mod_prefix .. "cycle-quality-up", function(event)
  cycle_quality(event, "up")
end)

script.on_event(mod_prefix .. "cycle-quality-down", function(event)
  cycle_quality(event, "down")
end)

local function toggle_gui(player)

  local frame = player.gui.screen[mod_prefix .. "frame"]
  if frame then frame.destroy() return end

  frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "frame",
    direction = "vertical",
    caption = {"item-name.quality-upgrade-planner"}
  }

  local inner = frame.add{
    type = "frame",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  local playerdata = storage.playerdata[player.index]

  for _, quality_category in ipairs(shared.quality_categories) do
    local flow = inner.add{
      type = "flow",
      style = "horizontal_flow",
    }
    flow.style.vertical_align = "center"

    local button = flow.add{
      type = "sprite-button",
      sprite = quality_category.sprite,
    }
    button.ignored_by_interaction = true

    local label = flow.add{
      type = "label",
      caption = {"", {"quality-category-name." .. quality_category.name}, " [img=info]"},
      tooltip = {"quality-category-description." .. quality_category.name},
    }
    label.style.font = "default-bold"

    local piston = flow.add{
      type = "flow",
    }
    piston.style.horizontally_stretchable = true

    local switch = flow.add{
      type = "switch",
      switch_state = playerdata.switch_states[quality_category.name] or quality_category.default_switch_state,
      left_label_caption = {"gui-constant.off"},
      right_label_caption = {"gui-constant.on"},
      tags = {
        action = mod_prefix .. "toggle-quality-category",
        quality_category_name = quality_category.name,
      },
    }
    if quality_category.not_yet_implemented then
      switch.enabled = false
      switch.allow_none_state = true
      switch.switch_state = "none"
    end
  end

  player.opened = frame
  frame.force_auto_center()
end

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    event.element.destroy()
  end
end)

script.on_event(defines.events.on_player_selected_area, function(event)
  if not is_quality_upgrade_planner_item[event.item] then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local playerdata = storage.playerdata[player.index]

  for _, quality_category in pairs(shared.quality_categories) do
    local switch_state = playerdata.switch_states[quality_category.name] or quality_category.default_switch_state
    if switch_state == "right" then
      Modes[quality_category.name](event, playerdata)
    end
  end
end)

script.on_event(defines.events.on_player_reverse_selected_area, function(event)
  if not is_quality_upgrade_planner_item[event.item] then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  toggle_gui(player)
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= "give-quality-upgrade-planner" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack then
    if cursor_stack.valid_for_read == true then
      if is_quality_upgrade_planner_item[cursor_stack.name] then
        toggle_gui(player)
      else
        player.clear_cursor()
      end
    end

    if cursor_stack.valid_for_read == false then -- only set the stack if the cursor actually was cleared (or empty to begin with)
      set_stack_to_quality_upgrade_planner(cursor_stack, prototypes.quality["normal"])
    end
  end
end)

script.on_event(defines.events.on_gui_switch_state_changed, function(event)
  -- game.print(serpent.line({event, event.element.tags}))
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "toggle-quality-category" then
    storage.playerdata[event.player_index].switch_states[tags.quality_category_name] = event.element.switch_state
    -- game.print(serpent.line(storage.playerdata[event.player_index]))
  end
end)
