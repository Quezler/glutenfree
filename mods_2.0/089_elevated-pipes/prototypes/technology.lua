local technology = {
  type = "technology",
  name = "elevated-pipe",
  icon = mod_directory .. "/graphics/technology/elevated-pipe.png",
  icon_size = 256,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = "elevated-pipe"
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
