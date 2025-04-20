local technology = {
  type = "technology",
  name = "pipe-pillar",
  icon = mod_directory .. "/graphics/technology/pipe-pillar.png",
  icon_size = 256,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = "pipe-pillar"
    },
    {
      type = "unlock-recipe",
      recipe = "iron-stick"
    }
  },
  prerequisites = {"steam-power", "steel-processing"},
  unit =
  {
    count = 100,
    ingredients = {{"automation-science-pack", 1}},
    time = 10
  }
}

data:extend{technology}
