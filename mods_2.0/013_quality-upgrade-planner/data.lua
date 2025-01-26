local item_sounds = require("__base__.prototypes.item_sounds")

local selection_tool = {
  type = "selection-tool",
  name = "quality-upgrade-planner",
  icons = {
    {icon = data.raw["upgrade-item"]["upgrade-planner"].icon},
    {icon = "__core__/graphics/icons/any-quality.png", scale = 0.375},
  },
  flags = {"spawnable"},
  subgroup = "tool",
  order = "c[automated-construction]-d[quality-upgrade-planner]",
  inventory_move_sound = item_sounds.planner_inventory_move,
  pick_sound = item_sounds.planner_inventory_pickup,
  drop_sound = item_sounds.planner_inventory_move,
  stack_size = 1,
  skip_fog_of_war = true,
  select =
  {
    border_color = {71, 255, 73},
    mode = {"upgrade"},
    cursor_box_type = "not-allowed",
    started_sound = { filename = "__core__/sound/upgrade-select-start.ogg" },
    ended_sound = { filename = "__core__/sound/upgrade-select-end.ogg" }
  },
  alt_select =
  {
    border_color = {0, 0, 0, 0},
    mode = {"nothing"},
    cursor_box_type = "not-allowed",
  },
  reverse_select =
  {
    border_color = {246, 255, 0},
    mode = {"downgrade"},
    cursor_box_type = "not-allowed",
    started_sound = { filename = "__core__/sound/upgrade-select-start.ogg" },
    ended_sound = { filename = "__core__/sound/upgrade-select-end.ogg" }
  },
  reverse_alt_select =
  {
    border_color = {0, 0, 0, 0},
    mode = {"nothing"},
    cursor_box_type = "not-allowed",
  },
  super_forced_select =
  {
    border_color = {0, 0, 0, 0},
    mode = {"nothing"},
    cursor_box_type = "not-allowed",
  },
}

local shortcut = {
  type = "shortcut",
  name = "give-quality-upgrade-planner",
  order = "b[blueprints]-k[quality-upgrade-planner]",
  action = "spawn-item",
  localised_name = {"shortcut.make-quality-upgrade-planner"},
--associated_control_input = "give-quality-upgrade-planner",
  technology_to_unlock = "construction-robotics",
  item_to_spawn = "quality-upgrade-planner",
  style = "green",
  icon = "__quality-upgrade-planner__/graphics/icons/shortcut-toolbar/mip/new-quality-upgrade-planner-x56.png",
  icon_size = 56,
  small_icon = "__quality-upgrade-planner__/graphics/icons/shortcut-toolbar/mip/new-quality-upgrade-planner-x24.png",
  small_icon_size = 24,
}

if mods["quality"] then
  shortcut.technology_to_unlock = "quality-module"
end

data:extend{selection_tool, shortcut}
