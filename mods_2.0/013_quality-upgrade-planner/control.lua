local mod_name = "quality-upgrade-planner"

local shared = require("shared")

local function on_configuration_changed()
  if storage.inventory then -- 1.0.1 - 1.0.8
    storage.inventory.destroy()
    storage.inventory = nil
  end

  storage.itemdata = storage.itemdata or {}
  storage.deathrattles = storage.deathrattles or {}
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function get_or_create_itemdata(itemstack)
  local itemdata = storage.itemdata[assert(itemstack.item_number)]

  if itemdata == nil then
    itemdata = {
      switch_states = {
        entities = "right",
      }
    }
    storage.itemdata[itemstack.item_number] = itemdata
    storage.deathrattles[script.register_on_object_destroyed(itemstack.item)] = {"itemdata", itemstack.item_number}
  end

  return itemdata
end

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
  local itemdata = get_or_create_itemdata(event.item)

  local frame = player.gui.screen[mod_prefix .. "frame"]
  if frame then frame.destroy() end

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

  for _, quality_category in ipairs(shared.quality_categories) do
    local flow = inner.add{
      type = "flow",
      style = "horizontal_flow",
    }
    flow.style.vertical_align = "center"

    local button = flow.add{
      type = "sprite-button",
      sprite = "quality-category-" .. quality_category.name,
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
      switch_state = quality_category.default_switch_state,
      left_label_caption = {"gui-constant.off"},
      right_label_caption = {"gui-constant.on"}
    }
    if quality_category.not_yet_implemented then
      switch.enabled = false
      switch.allow_none_state = true
      switch.switch_state = "none"
    end
  end

  player.opened = frame
  frame.force_auto_center()
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "frame" then
    event.element.destroy()
  end
end)

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "quality-upgrade-planner" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "quality-upgrade-planner" then
    game.print(serpent.line(get_or_create_itemdata(cursor_stack)))
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle[1] == "itemdata" then
      storage.itemdata[deathrattle[2]] = nil
      game.print("itemdata cleared")
    else
      error(serpent.block(deathrattle))
    end
  end
end)
