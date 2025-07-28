require("namespace")

require("prototypes.planet")

local search_n_replace = {
  ["__base__/graphics/icons/constant-combinator.png"] = "__stack-constant-combinator__/graphics/icons/stack-constant-combinator.png",
  ["__base__/graphics/entity/combinator/constant-combinator.png"] = "__stack-constant-combinator__/graphics/entity/combinator/stack-constant-combinator.png",
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
combinator.name = "stack-constant-combinator"
combinator.minable.result = "stack-constant-combinator"

do_search_n_replace(combinator)
-- log(serpent.block(combinator))
data:extend{combinator}

local item = table.deepcopy(data.raw["item"]["constant-combinator"])
item.name = "stack-constant-combinator"
item.place_result = "stack-constant-combinator"
item.order = "c[combinators]-d[stack-constant-combinator]"
item.stack_size = 10

do_search_n_replace(item)
-- log(serpent.block(item))
data:extend{item}

local recipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])
recipe.name = "stack-constant-combinator"
recipe.results = {{type = "item", name = "stack-constant-combinator", amount = 1}}
recipe.ingredients = {
  {type = "item", name = "arithmetic-combinator", amount = 4},
  {type = "item", name = "decider-combinator", amount = 1},
  {type = "item", name = "constant-combinator", amount = 1},
}

do_search_n_replace(recipe)
-- log(serpent.block(recipe))
data:extend{recipe}

local technology = data.raw["technology"]["advanced-combinators"]
for _, effect in ipairs(technology.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "selector-combinator" then
    table.insert(technology.effects, _ + 1, {
      type = "unlock-recipe", recipe = "stack-constant-combinator"
    })
    break
  end
end
