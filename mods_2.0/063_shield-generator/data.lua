local cover = {
  type = "simple-entity",
  name = "space-platform-foundation-protective-cover",

  selection_box = {{0, 0}, {0, 0}},
  collision_box = {{-0.1, -0.1}, {0.1, 0.1}},

  collision_mask = {layers = {empty_space = true}},
  protected_from_tile_building = false,
  resistances = {
    {
      type = "impact",
        percent = 100
    },
  }
}

data:extend{cover}
