local search_n_replace = {
  ['__base__/graphics/icons/constant-combinator.png'] = '__character-combinator__/graphics/icons/character-combinator.png',
  ['__base__/graphics/entity/combinator/constant-combinator.png'] = '__character-combinator__/graphics/entity/combinator/character-combinator.png',
  ['__base__/graphics/entity/combinator/hr-constant-combinator.png'] = '__character-combinator__/graphics/entity/combinator/hr-character-combinator.png',
}

-- i am too lazy to key-value replace these in all the directions myself lol, so hey: automatic function :)
local function do_search_n_replace(t)
  for key, value in pairs(t) do
    if type(value) == 'string' and search_n_replace[value] then
      t[key] = search_n_replace[value]
    end
    if type(value) == 'table' then
      do_search_n_replace(value)
    end
  end
end

local combinator = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
combinator.name = 'character-combinator'
combinator.minable.result = 'character-combinator'
combinator.item_slot_count = 10000 -- todo: guess based on the amount of items, fluids & signals (and their subcategory split row buffer thingies)
combinator.max_health = combinator.max_health * 5

do_search_n_replace(combinator)
-- log(serpent.block(combinator))
data:extend{combinator}

local item = table.deepcopy(data.raw['item']['constant-combinator'])
item.name = 'character-combinator'
item.place_result = 'character-combinator'
item.order = 'c[combinators]-d[character-combinator]'
item.stack_size = 10

do_search_n_replace(item)
-- log(serpent.block(item))
data:extend{item}

local recipe = table.deepcopy(data.raw['recipe']['constant-combinator'])
recipe.name = 'character-combinator'
recipe.result = 'character-combinator'
recipe.ingredients = {{'constant-combinator', 5}, {'pistol', 1}}

do_search_n_replace(recipe)
-- log(serpent.block(recipe))
data:extend{recipe}

local technology = data.raw['technology']['circuit-network']
for _, effect in ipairs(technology.effects) do
  if effect.type == 'unlock-recipe' and effect.recipe == 'constant-combinator' then
    table.insert(technology.effects, _ + 1, {
      type = 'unlock-recipe', recipe = 'character-combinator'
    })
    break
  end
end
