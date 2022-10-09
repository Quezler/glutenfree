local mod_prefix = 'glutenfree-space-exploration-deconstruction-planner-'

local shortcut = {
  type = "shortcut",
  name = mod_prefix .. 'shortcut',

  action = "spawn-item",
  item_to_spawn = mod_prefix .. 'item',
  technology_to_unlock = 'se-space-platform-scaffold',

  style = "default",
  icon = data.raw['shortcut']['give-deconstruction-planner'].icon,
  small_icon = data.raw['shortcut']['give-deconstruction-planner'].small_icon,
  disabled_small_icon = data.raw['shortcut']['give-deconstruction-planner'].disabled_small_icon,
}

local item = {
  type = "selection-tool",
  name = mod_prefix .. 'item',
  icon = "__glutenfree-space-exploration-deconstruction-planr__/graphics/items/greyscale-deconstruction-planner.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"hidden", "not-stackable", "spawnable", "only-in-cursor"},
  stack_size = 1,

  selection_color = {r = 0.25, g = 0.25, b = 0.25},
  alt_selection_color = {r = 0.25, g = 0.25, b = 0.25},

  selection_mode = {'deconstruct'},
  alt_selection_mode = {'cancel-deconstruct'},

  selection_cursor_box_type = 'not-allowed',
  alt_selection_cursor_box_type = 'not-allowed',

  always_include_tiles = true,
  tile_filters = {'se-space-platform-scaffold', 'se-space-platform-plating', 'se-spaceship-floor'},
  alt_tile_filters = {'se-space-platform-scaffold', 'se-space-platform-plating', 'se-spaceship-floor'},
},

-- data:extend({item, shortcut}) -- doesn't work
-- data:extend({shortcut, item}) -- complains that the item doesn't exist

-- invalid prototype array {}
-- data:extend({item})
-- data:extend({shortcut})

-- works
data:extend({shortcut})
data:extend({item})
