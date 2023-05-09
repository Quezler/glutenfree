-- print(serpent.block(data.raw['item-entity']['item-on-ground']))

-- {
--   collision_box = {
--     {
--       -0.14000000000000002,
--       -0.14000000000000002
--     },
--     {
--       0.14000000000000002,
--       0.14000000000000002
--     }
--   },
--   flags = {
--     "placeable-off-grid",
--     "not-on-map"
--   },
--   icon = "__core__/graphics/item-on-ground.png",
--   icon_size = 64,
--   minable = {
--     mining_time = 0.025
--   },
--   name = "item-on-ground",
--   selection_box = {
--     {
--       -0.17000000000000002,
--       -0.17000000000000002
--     },
--     {
--       0.17000000000000002,
--       0.17000000000000002
--     }
--   },
--   type = "item-entity"
-- }

local fannypack = table.deepcopy(data.raw['item-entity']['item-on-ground'])

fannypack.name = 'se-spaceship-clamp-fanny-pack'
fannypack.collision_mask = {}

data:extend({fannypack})

-- /c game.player.surface.create_entity{name = 'se-spaceship-clamp-fanny-pack', stack = {name = 'se-spaceship-clamp'}, position = game.player.selected.position}
