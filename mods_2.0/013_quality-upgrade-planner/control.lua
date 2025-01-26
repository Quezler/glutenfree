local mod_name = "quality-upgrade-planner"

local shared = require("shared")

local function on_configuration_changed()
  for _, inventory in ipairs(game.get_script_inventories(mod_name)[mod_name]) do
    inventory.destroy()
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local mod_prefix = "quality-upgrade-planner--"

script.on_event(mod_prefix .. "blueprint-book-next", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "quality-upgrade-planner" then
    local quality = prototypes.quality["legendary"]
    cursor_stack.label = quality.name
    cursor_stack.label_color = quality.color
  end
end)

script.on_event(mod_prefix .. "blueprint-book-previous", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "quality-upgrade-planner" then
    local quality = prototypes.quality["normal"]
    cursor_stack.label = quality.name
    cursor_stack.label_color = quality.color
  end
end)

script.on_event(defines.events.on_mod_item_opened, function(event)
  if event.item.name ~= "quality-upgrade-planner" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local frame = player.gui.screen[mod_prefix .. "frame"]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "frame",
    direction = "vertical",
    caption = {"item-name.quality-upgrade-planner"}
  }

  for _, quality_category in ipairs(shared.quality_categories) do
    local flow = frame.add{
      type = "flow",
      style = "horizontal_flow",
    }
    flow.style.vertical_align = "center"
    flow.add{
      type = "sprite-button",
      sprite = "quality-category-" .. quality_category,
    }
    local label = flow.add{
      type = "label",
      caption = {"quality-category." .. quality_category},
    }
    label.style.font = "default-bold"
  end

  player.opened = frame
  frame.force_auto_center()
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    event.element.destroy()
  end
end)
