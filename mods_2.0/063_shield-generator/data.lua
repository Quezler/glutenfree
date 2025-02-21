local cover = {
  type = "simple-entity",
  name = "space-platform-foundation-protective-cover",

  selection_box = {{ 0.0,  0.0}, { 0.0,  0.0}},
  collision_box = {{-0.4, -0.4}, { 0.4,  0.4}},

  collision_mask = {layers = {ground_tile = true}},
  resistances = {
    {
      type = "impact",
        percent = 100
    },
  }
}

data:extend{cover}
