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

-- construction radius of 32 / 4 = 8
-- 4 is the size of the power area sprite, so in blocks of 4 we need to fill up the area
-- todo: grab the values from the prototype and handle steps that aren't a multiple of 4

for w = 1, 8 do
  for h = 1, 8 do
    table.insert(rvp.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {(-1 + w * 2) / 8, (-1 + h * 2) / 8},
      blend_mode = "additive-soft", -- looks the best out of all the blend modes
    })
    table.insert(rvp.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {(-1 + w * 2) / 8, -(-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
  end
  for h = 1, 8 do
    table.insert(rvp.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {-(-1 + w * 2) / 8, (-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
    table.insert(rvp.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {-(-1 + w * 2) / 8, -(-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
  end
end

table.insert(rvp.layers, {
  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
  height = 8,
  priority = "extra-high-no-scale",
  width = 8,
})

local rvp2 = data.raw['electric-pole']['se-pylon-construction-radar'].radius_visualisation_picture
rvp2.layers = {}

-- construction radius of 256 / 64 = 4
-- 64 is the size of the power area sprite, so in blocks of 4 we need to fill up the area
-- todo: grab the values from the prototype and handle steps that aren't a multiple of 64

for w = 1, 2 do
  for h = 1, 2 do
    table.insert(rvp2.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {(-1 + w * 2) / 8, (-1 + h * 2) / 8},
      blend_mode = "additive-soft", -- looks the best out of all the blend modes
    })
    table.insert(rvp2.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {(-1 + w * 2) / 8, -(-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
  end
  for h = 1, 2 do
    table.insert(rvp2.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {-(-1 + w * 2) / 8, (-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
    table.insert(rvp2.layers, {
      filename = "__core__/graphics/visualization-construction-radius.png",
      height = 8,
      priority = "extra-high-no-scale",
      width = 8,
      shift = {-(-1 + w * 2) / 8, -(-1 + h * 2) / 8},
      blend_mode = "additive-soft",
    })
  end
end

table.insert(rvp2.layers, {
  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
  height = 8,
  priority = "extra-high-no-scale",
  width = 8,
})
