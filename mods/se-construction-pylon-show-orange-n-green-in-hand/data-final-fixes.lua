-- i'd say i'm allowed to require postprocess since i want that description, and that mod generates it :)

-- data.raw['electric-pole']['se-pylon-construction'].radius_visualisation_picture = {
--   layers = {
--     {
--       filename = "__core__/graphics/visualization-construction-radius.png",
--       height = 8,
--       priority = "extra-high-no-scale",
--       width = 8,
--       shift = {1 / 8, 1 / 8},
--     },
--     {
--       filename = "__core__/graphics/visualization-construction-radius.png",
--       height = 8,
--       priority = "extra-high-no-scale",
--       width = 8,
--       shift = {1 / 8, 3 / 8},
--     },
--     {
--       filename = "__core__/graphics/visualization-construction-radius.png",
--       height = 8,
--       priority = "extra-high-no-scale",
--       width = 8,
--       shift = {1 / 8, 5 / 8},
--     },
--     {
--       filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
--       height = 8,
--       priority = "extra-high-no-scale",
--       width = 8,
--       -- blend_mode = "overwrite",
--     },
--   }
-- }

local rvp = data.raw['electric-pole']['se-pylon-construction'].radius_visualisation_picture
rvp.layers = {}

for i = 1, 8 do
  table.insert(rvp.layers, {
    filename = "__core__/graphics/visualization-construction-radius.png",
    height = 8,
    priority = "extra-high-no-scale",
    width = 8,
    shift = {1 / 8, (-1 + i * 2) / 8},
  })
end

table.insert(rvp.layers, {
  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
  height = 8,
  priority = "extra-high-no-scale",
  width = 8,
})
