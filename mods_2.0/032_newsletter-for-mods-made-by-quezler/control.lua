local my_mods = require("scripts.database") --[[@as table]]

local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local mod_prefix = "newsletter-for-mods-made-by-quezler-"
local rich_text_crater = string.format("[img=%s]", mod_prefix .. "crater")

-- [gps=0,0,https://mods.factorio.com/mod/newsletter-for-mods-made-by-quezler] [gps=0,0,nauvis] [gps=0,0,nauviz]
script.on_event(defines.events.on_player_clicked_gps_tag, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  log(serpent.block(my_mods))

  if true then
    player.set_goal_description(string.format("[img=%s] Quezler released a new mod!", mod_prefix .. "crater"))
    player.gui.goal.add{
      type = "label",
      name = mod_prefix .. "goal-label",
      caption = "click here to view his list of mods.",
      raise_hover_events = true,
    }
    return
  end

  local mod_url = "https://mods.factorio.com/mod/newsletter-for-mods-made-by-quezler"

  local textfield = player.gui.center[mod_prefix .. "textfield"]
  if textfield == nil then
    textfield = player.gui.center.add{
      type = "textfield",
      name = mod_prefix .. "textfield",

      text = mod_url,
    }
  else
    textfield.text = mod_url
  end

  textfield.focus()
  textfield.select_all()

  textfield.style.width = 750 -- fits "https://mods.factorio.com/mod/wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" (49 max length, w max width)
  textfield.style.horizontal_align = "center"

  player.print(string.format("[img=%s] Quezler released a new mod!", mod_prefix .. "crater"))
end)

local function close_textfield(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local textfield = player.gui.center[mod_prefix .. "textfield"]
  if textfield == nil then return end

  textfield.destroy()
end

script.on_event(mod_prefix .. "leftclick", close_textfield)

-- so that walking with WASD makes you close the textfield as well
script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element.name == mod_prefix .. "textfield" then
    close_textfield(event)
  end
end)

script.on_event(defines.events.on_gui_hover, function(event)
  if event.element.name == mod_prefix .. "goal-label" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.set_goal_description("")
    event.element.destroy()
  end
end)

commands.add_command("mods", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]

  local frame = player.gui.screen.add{
    type = "frame",
    caption = {"", rich_text_crater, " ", "Quezler's mods"},
  }
  -- frame.style.width = 500
  frame.force_auto_center()

  -- local inner = frame.add{
  --   type = "frame",
  --   style = "inside_shallow_frame_with_padding",
  --   direction = "vertical",
  -- }

  -- local scroll = inner.add{
  local scroll = frame.add{
    type = "scroll-pane",
    vertical_scroll_policy = "auto-and-reserve-space",
    horizontal_scroll_policy = "never",
  }
  scroll.style.width = 500
  scroll.style.height = 700

  local table = scroll.add{
    type = "table",
    style = "table_with_selection",
    column_count = 1,
  }
  table.style.left_cell_padding = 4
  table.style.right_cell_padding = 4

  for _, mod in ipairs(my_mods) do
    local row = table.add{
      type = "button",
    }
    row.style.natural_width = 460
    -- row.style.left_padding = 20
    -- row.style.right_padding = 20
    -- row.style.top_padding = 20
    -- row.style.bottom_padding = 20

    local row_flow = row.add{
      type = "flow",
      -- name = "row_flow",
      direction = "horizontal",
      ignored_by_interaction = true
    }

    row_flow.add{
      type = "label",
      caption = mod.name,
    }
  end

end)
