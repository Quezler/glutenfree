local my_mods = require("scripts.database") --[[@as table]]

local mod_prefix = "newsletter-for-mods-made-by-quezler-"
local rich_text_crater = string.format("[img=%s]", mod_prefix .. "crater")

local goal_text = rich_text_crater .. " Use the shortcut with this icon once."

script.on_init(function()
  storage.playerdata = {}

  for _, player in pairs(game.players) do
    storage.playerdata[player.index] = {}
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  storage.playerdata[event.player_index] = {}
end)

script.on_event(defines.events.on_player_removed, function(event)
  storage.playerdata[event.player_index] = nil
end)

local function close_textfield(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local textfield_frame = player.gui.screen[mod_prefix .. "main-frame"]
  if textfield_frame == nil then return end

  textfield_frame.destroy()
end

local function sort_newest_first(mod_a, mod_b)
  return mod_a.created_at > mod_b.created_at
end

function get_ordinal_suffix(number)
  local suffix = "th"

  if     number % 10 == 1 then
      suffix = "st"
  elseif number % 10 == 2 then
      suffix = "nd"
  elseif number % 10 == 3 then
      suffix = "rd"
  end

  return suffix
end

local function get_human_calendar_date()
  local version = script.active_mods["newsletter-for-mods-made-by-quezler"]
  if string.len(version) ~= 17 then version = "12024.11114.11645" end

  local year = string.sub(version, 2, 5)
  local month = string.sub(version, 9, 10)
  local day = string.sub(version, 10, 11)

  return year, month, day
end

local function open_for_player(player)
  local playerdata = storage.playerdata[player.index]
  playerdata.opened_once = true

  if player.get_goal_description() == goal_text then
    player.set_goal_description("")
  end

  local main_frame = player.gui.screen[mod_prefix .. "main-frame"]
  if main_frame then main_frame.destroy() end
  main_frame = player.gui.screen.add{
    type = "frame",
    name = mod_prefix .. "main-frame",
    style = "invisible_frame",
    direction = "vertical",
  }

  local year, month, day = get_human_calendar_date()

  local frame = main_frame.add{
    type = "frame",
    caption = {"",
      rich_text_crater,
      " ",
      "Quezler's mods [font=default-tiny-bold][color=white]as of",
      " ",
      {"newsletter-for-mods-made-by-quezler.month-" .. month},
      " ",
      day .. get_ordinal_suffix(tonumber(day)) .. "[/color][/font]"
    },
    direction = "vertical",
  }
  frame.drag_target = main_frame

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

  frame.add{
    type = "label",
    caption = string.format("Hello! even though i have [font=default-bold]%d[/font] mods i suck at guis, if you're a fellow [font=default-bold]modder[/font] with [font=default-bold]gui[/font] knowledge, [font=default-bold]help[/font] is very much welcome.", #my_mods)
  }

  frame.add{
    type = "label",
    caption = string.format("And well [font=default-bold]if you are a player[/font] here's a list of my mods, just [font=default-bold]click[/font] one and then [font=default-bold]copy[/font] the url into a [font=default-bold]browser[/font]. (grey is not disabled)")
  }

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

    local line_1 = row.add{
      type = "flow",
    }

    local line_1_a = line_1.add{
      type = "label",
      caption = mod.title,
      style = "caption_label",
    }

    -- local notification = line_1.add{
    --   type = "sprite",
    --   sprite = "utility/notification",
    --   -- style = "se_zonelist_row_cell_type_notification"
    -- }

    local line_1_b = line_1.add{
      type = "empty-widget",
    }
    line_1_b.style.horizontally_stretchable = true

    local line_1_c = line_1.add{
      type = "button",
      -- caption = script.active_mods[mod.name] and "[color=green]installed[/color]" or "install",
      caption = script.active_mods[mod.name] and "installed" or "install",
      enabled = script.active_mods[mod.name] == nil,
      ignored_by_interaction = script.active_mods[mod.name] ~= nil,
    }

    local line_2 = row.add{
      type = "label",
      caption = "[font=default-small]" .. mod.summary .. "[/font]",
    }

    local date = string.sub(mod.created_at, 1, 10)
    date = string.gsub(date, "%-", ". ")

    local version_color = "red"
    version_color = mod.latest_release.info_json.factorio_version == "1.1" and "orange" or version_color
    version_color = mod.latest_release.info_json.factorio_version == "2.0" and "green" or version_color
    local version_string = string.format("[font=default-tiny-bold][color=%s]%s[/color][/font]", version_color, mod.latest_release.info_json.factorio_version)

    local line_3 = row.add{
      type = "label",
      caption = string.format("%s [font=default-bold]%s[/font] [font=default-tiny-bold]%s[/font]", version_string, date, mod.category),
    }

    if mod.deprecated then
      line_3.caption = line_3.caption .. " [font=default-bold](deprecated)[/font]"
    end
  end

  main_frame.force_auto_center()
  player.opened = main_frame
end

local function get_parent_with_action_tag(element, action_tag)
  if element.tags and element.tags.action == action_tag then return element end

  if element.parent then return get_parent_with_action_tag(element.parent, action_tag) end
end

script.on_event(defines.events.on_gui_click, function(event)
  -- game.print(event.tick)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local parent_with_action_tag = get_parent_with_action_tag(event.element, mod_prefix .. "show-url-for-mod")
  if parent_with_action_tag then
    local mod_url = "https://mods.factorio.com/mod/" .. parent_with_action_tag.tags.mod_name

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

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == mod_prefix .. "shotcut" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    open_for_player(player)
  end
end)
