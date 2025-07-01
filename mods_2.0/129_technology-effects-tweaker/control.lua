require("namespace")

script.on_init(function()
  log(serpent.block(prototypes.mod_data[mod_prefix .. "original-technology-effects"].data))
end)

local function last_touched_by_this_mod(prototype)
  local history = prototypes.get_history(prototype.type, prototype.name)

  return history.changed[#history.changed] == mod_name
end

local function technology_passes_search(technology_name, search)
  return technology_name:find(search, 1, true) ~= nil
end

local technology_names = {}
for technology_name, _ in pairs(prototypes.mod_data[mod_prefix .. "original-technology-effects"].data) do
  technology_names[technology_name] = true
end
for technology_name, _ in pairs(prototypes.technology) do
  if not technology_names[technology_name] then
    technology_names[technology_name] = false
  end
end

local sorted_technology_names = {}
for technology_name, _ in pairs(technology_names) do
  table.insert(sorted_technology_names, technology_name)
end
table.sort(sorted_technology_names)

local gui_frame_name = mod_prefix .. "frame"

local function open_gui(player)
  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = {"mod-name." .. mod_name},
  }
  frame.style.maximal_height = 500

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame",
    direction = "vertical",
  }

  -- inner.add{
  --   type = "button",
  --   style = "available_technology_slot",
  -- }

  local textfield = inner.add{
    type = "textfield",
    name = mod_prefix .. "textfield",
  }
  textfield.style.minimal_width = 300

  local scroll_pane = inner.add{
    type = "scroll-pane",
    name = "scroll-pane",
    style = "list_box_scroll_pane",
    vertical_scroll_policy = "always",
  }
  scroll_pane.style.horizontally_stretchable = true
  scroll_pane.style.minimal_width = 300
  scroll_pane.style.bottom_padding = 4
  scroll_pane.style.minimal_height = frame.style.maximal_height - 80

  for _, technology_name in pairs(sorted_technology_names) do
    local from_data_stage = technology_names[technology_name]
    local prototype = prototypes.technology[technology_name]

    local flow = scroll_pane.add{
      type = "flow",
      name = technology_name,
      style = "horizontal_flow",
    }
    flow.style.maximal_height = 24

    local button = flow.add{
      type = "button",
      style = "list_box_item",
      tooltip = technology_name,
      tags = {
        action = mod_prefix .. "select-technology",
        technology_name = technology_name,
      },
    }
    button.style.horizontally_stretchable = true

    local rich_text = prototype and string.format("[technology=%s] ", technology_name) or "[item=item-unknown] "
    local localized_name = prototype and prototype.localised_name or {"technology-name." .. technology_name}
    local label = button.add{
      type = "label",
      caption = {"", rich_text, localized_name},
    }

    if not prototype then
      label.style.font_color = {1, 0, 0}
    elseif not from_data_stage then
      label.style.font_color = {0, 1, 0}
    -- elseif prototype.hidden then
    --   label.style.font_color = {0.5, 0.5, 0.5}
    elseif not last_touched_by_this_mod(prototype) then
      label.style.font_color = {1, 0.5, 0}
    end
  end

  player.opened = frame
  frame.force_auto_center()
end

commands.add_command(mod_name, nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  open_gui(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == gui_frame_name then
    event.element.destroy()
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element.name == mod_prefix .. "textfield" then
    local root = event.element.parent.parent --[[@as LuaGuiElement]]
    assert(root.name == gui_frame_name)
    local query = event.element.text
    for _, element in pairs(root["inner"]["scroll-pane"].children) do
      element.visible = technology_passes_search(element.name, query)
    end
  end
end)
