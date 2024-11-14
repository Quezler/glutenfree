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
  local textfield_frame = player.gui.screen[mod_prefix .. "textfield-frame"]
  if textfield_frame == nil then return end

  textfield_frame.destroy()
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
  -- frame.style.width = 500

  textfield_frame = main_frame.add{
    type = "frame",
    name = mod_prefix .. "textfield-frame",
  }
  textfield_frame.style.padding = 2

  local textfield = textfield_frame.add{
    type = "textfield",
    name = mod_prefix .. "textfield",

    enabled = false,
  }

  textfield.style.width = 750 -- fits "https://mods.factorio.com/mod/wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" (49 max length, w max width)
  textfield.style.horizontal_align = "center"

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

  local lua_table = scroll.add{
    type = "table",
    style = "table_with_selection",
    column_count = 1,
  }
  lua_table.style.left_cell_padding = 4
  lua_table.style.right_cell_padding = 4

  table.sort(my_mods, sort_newest_first)

  for _, mod in ipairs(my_mods) do
    local row = lua_table.add{
      type = "button",
      -- name = mod_prefix .. "row-button-mod",
    }
    row.style.width = 460
    -- row.style.left_padding = 20
    -- row.style.right_padding = 20
    -- row.style.top_padding = 20
    -- row.style.bottom_padding = 20
    row.tags = {
      action = mod_prefix .. "show-url-for-mod",
      mod_name = mod.name,
    }

    local row_flow = row.add{
      type = "flow",
      -- name = "row_flow",
      direction = "horizontal",
      ignored_by_interaction = true
    }

    row_flow.add{
      type = "label",
      caption = mod.title,
    }
  end

  main_frame.force_auto_center()
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  -- if event.element.name == mod_prefix .. "row-button-mod" then
  if event.element.tags.action == mod_prefix .. "show-url-for-mod" then
    local mod_url = "https://mods.factorio.com/mod/" .. event.element.tags.mod_name

    local textfield = player.gui.screen[mod_prefix .. "main-frame"][mod_prefix .. "textfield-frame"][mod_prefix .. "textfield"]

    textfield.text = mod_url
    textfield.enabled = true

    textfield.focus()
    textfield.select_all()
  end
end)
