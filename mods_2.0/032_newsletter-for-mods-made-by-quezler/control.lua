local my_mods = require("scripts.database") --[[@as table]]

local mod_prefix = "newsletter-for-mods-made-by-quezler-"
local rich_text_crater = string.format("[img=%s]", mod_prefix .. "crater")

local function close_textfield(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local textfield_frame = player.gui.screen[mod_prefix .. "main-frame"]
  if textfield_frame == nil then return end

  textfield_frame.destroy()
end

script.on_event(defines.events.on_gui_hover, function(event)
  if event.element.name == mod_prefix .. "goal-label" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.set_goal_description("")
    event.element.destroy()
  end
end)

local function sort_newest_first(mod_a, mod_b)
  return mod_a.created_at > mod_b.created_at
end

commands.add_command("mods", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]

  local main_frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "main-frame",
    style = "invisible_frame",
    direction = "vertical",
  }

  local frame = main_frame.add{
    type = "frame",
    caption = {"", rich_text_crater, " ", "Quezler's mods"},
  }
  frame.drag_target = main_frame
  -- frame.style.width = 500

  textfield_frame = main_frame.add{
    type = "frame",
    name = mod_prefix .. "textfield-frame",
  }
  textfield_frame.style.padding = 2

  local textfield = textfield_frame.add{
    type = "textfield",
    name = mod_prefix .. "textfield",

    -- text = "https://mods.factorio.com/mod/newsletter-for-mods-made-by-quezler",
    enabled = false,
  }

  textfield.style.width = 750 -- fits "https://mods.factorio.com/mod/wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" (49 max length, w max width)
  textfield.style.horizontal_align = "center"
  -- textfield.style.disabled_font_color = {1, 1, 1}

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
  scroll.style.width = 738
  scroll.style.height = 700

  local lua_table = scroll.add{
    type = "table",
    -- style = "table_with_selection",
    column_count = 1,
  }
  lua_table.style.left_cell_padding = 4
  lua_table.style.right_cell_padding = 4
  lua_table.style.top_margin = 4
  lua_table.style.bottom_margin = 4

  lua_table.style.vertical_spacing = 8
  lua_table.style.horizontal_spacing = 8

  table.sort(my_mods, sort_newest_first)

  for i, mod in ipairs(my_mods) do
    -- local row = lua_table.add{
    --   type = "button",
    --   -- name = mod_prefix .. "row-button-mod",
    -- }

    local row = lua_table.add{
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      direction = "vertical",
    }
    row.style.padding = 6
    row.style.width = 708
    row.tags = {
      action = mod_prefix .. "show-url-for-mod",
      mod_name = mod.name,
    }

    -- local row_flow = row.add{
    --   type = "flow",
    --   direction = "vertical",
    -- }

    -- row.add{
    --   type = "label",
    --   caption = "#00" .. i,
    --   style = "semibold_label",
    --   ignored_by_interaction = true,
    -- }


    row.add{
      type = "label",
      caption = mod.title,
      style = "caption_label",
      ignored_by_interaction = true,
    }

    row.add{
      type = "label",
      caption = "[font=default-small]" .. mod.summary .. "[/font]",
      ignored_by_interaction = true,
    }
  end

  main_frame.force_auto_center()
  player.opened = main_frame
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  if event.element.tags.action == mod_prefix .. "show-url-for-mod" then
    local mod_url = "https://mods.factorio.com/mod/" .. event.element.tags.mod_name

    local textfield = player.gui.screen[mod_prefix .. "main-frame"][mod_prefix .. "textfield-frame"][mod_prefix .. "textfield"]

    textfield.text = mod_url
    textfield.enabled = true

    textfield.focus()
    textfield.select_all()
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod_prefix .. "main-frame" then
    event.element.destroy()
  end
end)
