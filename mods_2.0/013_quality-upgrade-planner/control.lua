local mod_name = "quality-upgrade-planner"

local shared = require("shared")

local function on_configuration_changed()
  if storage.inventory then -- 1.0.1 - 1.0.8
    storage.inventory.destroy()
    storage.inventory = nil
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
    switch.ignored_by_interaction = true -- todo: itemdata
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

local function set_mapper(upgrade_planner, i, entity_name, quality_name)
  upgrade_planner.set_mapper(i, "from", {type = "entity", name = entity_name})
  upgrade_planner.set_mapper(i, "to"  , {type = "entity", name = entity_name, quality = quality_name})
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "quality-upgrade-planner" then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack and cursor_stack.valid_for_read and is_quality_upgrade_planner_item[cursor_stack.name] then
    -- game.print(serpent.line(get_or_create_itemdata(cursor_stack)))

    local inventory = game.create_inventory(1)
    local upgrade_planner = inventory[1]
    upgrade_planner.set_stack({name = "upgrade-planner"})

    local map = {}
    for i, entity in ipairs(event.entities) do
      map[(entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype).name] = event.quality
    end

    local i = 0
    for entity_name, quality_name in pairs(map) do
      i = i + 1
      set_mapper(upgrade_planner, i, entity_name, quality_name)
    end

    event.surface.upgrade_area{
      area = event.area,
      force = player.force,
      player = player,
      skip_fog_of_war = true,
      item = upgrade_planner,
    }

    inventory.destroy()
  end
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
