require("namespace")

local search_n_replace = {
  ["__base__/graphics/icons/constant-combinator.png"] = "__hand-held-combinator__/graphics/icons/hand-held-combinator.png",
  ["__base__/graphics/entity/combinator/constant-combinator.png"] = "__hand-held-combinator__/graphics/entity/combinator/hand-held-combinator.png",
}

-- i am too lazy to key-value replace these in all the directions myself lol, so hey: automatic function :)
local function do_search_n_replace(t)
  for key, value in pairs(t) do
    if type(value) == "string" and search_n_replace[value] then
      t[key] = search_n_replace[value]
    end
    if type(value) == "table" then
      do_search_n_replace(value)
    end
  end
end

local combinator = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combinator.name = "hand-held-combinator"
combinator.minable.result = "hand-held-combinator"

do_search_n_replace(combinator)
-- log(serpent.block(combinator))
data:extend{combinator}

local item = table.deepcopy(data.raw["item"]["constant-combinator"])
item.name = "hand-held-combinator"
item.place_result = "hand-held-combinator"
item.order = "c[combinators]-d[hand-held-combinator]"
item.stack_size = 10

do_search_n_replace(item)
-- log(serpent.block(item))
data:extend{item}

local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])
recipe.name = "hand-held-combinator"
recipe.results = {{type = "item", name = "hand-held-combinator", amount = 1}}
recipe.ingredients = {
  {type = "item", name = "constant-combinator", amount = 1},
  {type = "item", name = "burner-inserter", amount = 1},
}

do_search_n_replace(recipe)
-- log(serpent.block(recipe))
data:extend{recipe}

local technology = data.raw["technology"]["circuit-network"]
table.insert(technology.effects, {
  type = "unlock-recipe", recipe = "hand-held-combinator"
})
