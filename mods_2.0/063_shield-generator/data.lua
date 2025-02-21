local cover = {
  type = "simple-entity",
  name = "space-platform-foundation-protective-cover",

  selection_box = {{0, 0}, {0, 0}},
  collision_box = {{0, 0}, {0, 0}},

  collision_mask = {layers = {}},
  resistances = {
    {
      type = "impact",
        percent = 100
    },
  }
}

data:extend{cover}
