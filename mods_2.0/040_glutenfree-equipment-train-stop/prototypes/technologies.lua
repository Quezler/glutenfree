data:extend({
  {
    type = "technology",
    name = "glutenfree-equipment-train-stop",
    icons = {
      {
        icon = "__base__/graphics/technology/railway.png",
        icon_size = 256,
      },
      {
        icon = "__base__/graphics/icons/arrows/up-arrow.png",
        icon_size = 64,
        shift = {30, 20},
        scale = 1.5,
        floating = true,
        tint = {r = 0, g = 0, b = 0, a = 1},
      },
      {
        icon = "__base__/graphics/icons/arrows/up-arrow.png",
        icon_size = 64,
        shift = {30, 20},
        scale = 1.4,
        floating = true,
        tint = {r = 0, g = 0.9, b = 0, a = 1},
      },
    },
    prerequisites = {
      "solar-panel-equipment",
      "automated-rail-transportation",
      "robotics",
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "glutenfree-equipment-train-stop-station",
      },
    },
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
  },
})
