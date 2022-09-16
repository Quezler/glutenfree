local container = table.deepcopy(data.raw['container']['wooden-chest'])

container.name = 'alt-mode-indicator-for-1x1-loaders'
container.inventory_size = 5 -- only 4 are shown for containers in alt mode, but oh well
container.selectable_in_game = false -- flag applied during runtime

container.collision_mask = {}
container.se_allow_in_space = true

container.flags = {
  'not-on-map',
  'not-blueprintable',
  'not-deconstructable',
  'hidden',
  'no-automated-item-removal',
  'no-automated-item-insertion',
  -- 'not-selectable-in-game',
  'not-upgradable',
  'not-in-kill-statistics',
}

require("util")
container.picture = util.empty_sprite()

data:extend({container})
