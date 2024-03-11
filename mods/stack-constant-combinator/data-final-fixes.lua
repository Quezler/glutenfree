local search_n_replace = {
  ['__base__/graphics/icons/constant-combinator.png'] = '__stack-constant-combinator__/graphics/icons/stack-constant-combinator.png',
  ['__base__/graphics/entity/combinator/constant-combinator.png'] = '__stack-constant-combinator__/graphics/entity/combinator/stack-constant-combinator.png',
  ['__base__/graphics/entity/combinator/hr-constant-combinator.png'] = '__stack-constant-combinator__/graphics/entity/combinator/hr-stack-constant-combinator.png',
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
combinator.name = 'stack-constant-combinator'
combinator.minable.result = 'stack-constant-combinator'
-- combinator.item_slot_count = estimate_required_combinator_slots()
-- combinator.max_health = combinator.max_health * 5

do_search_n_replace(combinator)
-- log(serpent.block(combinator))
data:extend{combinator}

local item = table.deepcopy(data.raw['item']['constant-combinator'])
item.name = 'stack-constant-combinator'
item.place_result = 'stack-constant-combinator'
item.order = 'c[combinators]-d[stack-constant-combinator]'
-- item.stack_size = 10

do_search_n_replace(item)
-- log(serpent.block(item))
data:extend{item}

local recipe = table.deepcopy(data.raw['recipe']['constant-combinator'])
recipe.name = 'stack-constant-combinator'
recipe.result = 'stack-constant-combinator'
recipe.ingredients = {{'constant-combinator', 1}, {'arithmetic-combinator', 1}}

do_search_n_replace(recipe)
-- log(serpent.block(recipe))
data:extend{recipe}

local technology = data.raw['technology']['circuit-network']
for _, effect in ipairs(technology.effects) do
  if effect.type == 'unlock-recipe' and effect.recipe == 'constant-combinator' then
    table.insert(technology.effects, _ + 1, {
      type = 'unlock-recipe', recipe = 'stack-constant-combinator'
    })
    break
  end
end

local internal = table.deepcopy(data.raw['constant-combinator']['stack-constant-combinator'])
internal.name = 'stack-constant-combinator-internal'
internal.minable = nil
-- internal.collision_mask = {}
internal.flags = {"not-blueprintable", "not-deconstructable"}

internal.selectable_in_game = false
-- internal.sprites = nil
internal.draw_circuit_wires = false

data:extend{internal}
