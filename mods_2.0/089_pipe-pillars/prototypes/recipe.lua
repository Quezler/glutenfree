local recipe = {
  type = "recipe",
  name = "pipe-pillar",
  ingredients = {
    {type = "item", name = "pipe", amount = 5},
    {type = "item", name = "steel-plate", amount = 4},
    {type = "item", name = "iron-stick", amount = 20},
  },
  results = {{type="item", name="pipe-pillar", amount=1}},
  enabled = false
}

data:extend{recipe}
