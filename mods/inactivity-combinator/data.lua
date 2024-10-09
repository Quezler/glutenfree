-- local function replace_recursive(t, search, replace)
--   for k, v in pairs(t) do
--     if type(v) == "table" then
--       replace_recursive(v, search, replace)
--     elseif v == search then
--       t[k] = replace
--     end
--   end
-- end

local combinator = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"])

combinator.name = "inactivity-combinator"
combinator.placeable_by = {item = "decider-combinator", count = 1}

-- combinator.icon = "__inactivity-combinator__/graphics/icons/inactivity-combinator.png"

-- replace_recursive(combinator.sprites,
--                  '__base__/graphics/entity/combinator/constant-combinator.png',
-- '__inactivity-combinator__/graphics/entity/combinator/inactivity-combinator.png')

-- replace_recursive(combinator.sprites,
--                  '__base__/graphics/entity/combinator/hr-constant-combinator.png',
-- '__inactivity-combinator__/graphics/entity/combinator/hr-inactivity-combinator.png')

local search_n_replace = {
  ['__base__/graphics/icons/decider-combinator.png'] = '__inactivity-combinator__/graphics/icons/inactivity-combinator.png',
  ['__base__/graphics/entity/combinator/decider-combinator.png'] = '__inactivity-combinator__/graphics/entity/combinator/inactivity-combinator.png',
  ['__base__/graphics/entity/combinator/hr-decider-combinator.png'] = '__inactivity-combinator__/graphics/entity/combinator/hr-inactivity-combinator.png',
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

do_search_n_replace(combinator)

data:extend{combinator}
