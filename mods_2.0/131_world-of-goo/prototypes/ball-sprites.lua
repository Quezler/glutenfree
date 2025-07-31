-- goo types

data:extend{{
  type = "sprite",
  name = "common-body",
  layers = {
    {
      filename = mod_directory .. "/graphics/balls/generic-shadow.png",
      priority = "extra-high",
      width = 59,
      height = 59,
      scale = 0.4,
    },
    {
      filename = mod_directory .. "/graphics/balls/common-body.png",
      width = 64,
      height = 64,
      scale = 0.25,
    },
  }
}}

data:extend{{
  type = "sprite",
  name = "water-body",
  layers = {
    {
      filename = mod_directory .. "/graphics/balls/water-shadow.png",
      priority = "extra-high",
      width = 59,
      height = 59,
      scale = 0.4,
    },
    {
      filename = mod_directory .. "/graphics/balls/water-body.png",
      width = 64,
      height = 64,
      scale = 0.25,
    },
  }
}}

-- goo faces

data:extend{{
  type = "sprite",
  name = "generic-eye-1",
  filename = mod_directory .. "/graphics/balls/generic-eye-1.png",
  width = 32,
  height = 32,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-2",
  filename = mod_directory .. "/graphics/balls/generic-eye-2.png",
  width = 23,
  height = 23,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-eye-3",
  filename = mod_directory .. "/graphics/balls/generic-eye-3.png",
  width = 16,
  height = 16,
  scale = 0.25,
}}

data:extend{{
  type = "sprite",
  name = "generic-pupil",
  filename = mod_directory .. "/graphics/balls/generic-pupil.png",
  width = 8,
  height = 8,
  scale = 0.25,
}}
