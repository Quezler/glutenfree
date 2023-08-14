print(serpent.block( data.raw['resource']['uranium-ore'] ))

data:extend({{
  type = "resource",
  name = "square-hole",

  stage_counts = {
    10000,
    6330,
    3670,
    1930,
    870,
    270,
    100,
    50
  },

  stages = {
    sheet = {
      filename = "__base__/graphics/entity/uranium-ore/uranium-ore.png",
      frame_count = 8,
      height = 64,
      hr_version = {
        filename = "__base__/graphics/entity/uranium-ore/hr-uranium-ore.png",
        frame_count = 8,
        height = 128,
        priority = "extra-high",
        scale = 0.5,
        variation_count = 8,
        width = 128,
        tint = {0, 0, 0, 0} -- invisible
      },
      priority = "extra-high",
      variation_count = 8,
      width = 64,
      tint = {0, 0, 0, 0} -- invisible
    }
  },

  minable = {
    -- fluid_amount = 10,
    mining_particle = "stone-particle",
    mining_time = 2,
    -- required_fluid = "sulfuric-acid",
    -- required_fluid = "fluid-unknown",
  },

}})
