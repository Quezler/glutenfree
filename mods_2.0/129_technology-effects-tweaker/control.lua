require("namespace")

script.on_init(function()
  log(serpent.block(prototypes.mod_data[mod_prefix .. "original-technology-effects"].data))
end)

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

  local textfield = inner.add{
    type = "textfield",
    caption = "search",
  }
  textfield.style.minimal_width = 300

  local scroll_pane = inner.add{
    type = "scroll-pane",
    -- name = "scroll-pane",
    style = "list_box_scroll_pane",
    vertical_scroll_policy = "always",
  }
  scroll_pane.style.horizontally_stretchable = true
  scroll_pane.style.minimal_width = 300
  scroll_pane.style.bottom_padding = 4

  for _, technology in pairs(prototypes.technology) do
    local flow = scroll_pane.add{
      type = "flow",
      style = "horizontal_flow",
    }
    flow.style.maximal_height = 24

    local button = flow.add{
      type = "button",
      style = "list_box_item",
      tags = {
        action = mod_prefix .. "select-technology",
        technology_name = technology.name,
      },
    }
    button.style.horizontally_stretchable = true

    button.add{
      type = "label",
      caption = {"", string.format("[technology=%s] ", technology.name), technology.localised_name},
    }
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
