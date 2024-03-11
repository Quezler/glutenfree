local search_n_replace = {
  ['__base__/graphics/icons/decider-combinator.png'] = '__lua-powered-combinator-demo__/graphics/icons/lua-combinator.png',
  ['__base__/graphics/entity/combinator/decider-combinator.png'] = '__lua-powered-combinator-demo__/graphics/entity/combinator/lua-combinator.png',
  ['__base__/graphics/entity/combinator/hr-decider-combinator.png'] = '__lua-powered-combinator-demo__/graphics/entity/combinator/hr-lua-combinator.png',
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

local combinator = table.deepcopy(data.raw['decider-combinator']['decider-combinator'])
combinator.name = 'lua-combinator'
combinator.minable.result = 'lua-combinator'
combinator.energy_source = {type = 'void'}

do_search_n_replace(combinator)
data:extend{combinator}

local item = table.deepcopy(data.raw['item']['decider-combinator'])
item.name = 'lua-combinator'
item.place_result = 'lua-combinator'
item.order = 'c[combinators]-d[lua-combinator]'

do_search_n_replace(item)
data:extend{item}

local recipe = table.deepcopy(data.raw['recipe']['decider-combinator'])
recipe.name = 'lua-combinator'
recipe.result = 'lua-combinator'
recipe.ingredients = {{'constant-combinator', 1}, {'decider-combinator', 1}}

do_search_n_replace(recipe)
data:extend{recipe}

local technology = data.raw['technology']['circuit-network']
for _, effect in ipairs(technology.effects) do
  if effect.type == 'unlock-recipe' and effect.recipe == 'decider-combinator' then
    table.insert(technology.effects, _ + 1, {
      type = 'unlock-recipe', recipe = 'lua-combinator'
    })
    break
  end
end

local internal = table.deepcopy(data.raw['constant-combinator']['constant-combinator'])
internal.name = 'lua-combinator-internal'
internal.minable = nil
internal.collision_mask = {}
internal.flags = {"placeable-off-grid"}

internal.selectable_in_game = false
internal.sprites = nil
internal.draw_circuit_wires = false

data:extend{internal}
