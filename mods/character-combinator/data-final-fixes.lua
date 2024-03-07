local function estimate_required_combinator_slots()
  -- local function table_contains(t, value)
  --   for k, v in pairs(t) do
  --     if v == value then return true end
  --   end
  --   return false
  -- end

  -- local function next_10(i)
  --   repeat
  --     if (i % 10) == 0 then return i end
  --     i = i + 1
  --   until(false)
  -- end  

  -- for _, item_group in pairs(data.raw['item-group']) do
  --   item_group.subgroups = {}
  -- end

  -- local subgroup_children = {}
  -- for _, item_subgroup in pairs(data.raw['item-subgroup']) do
  --   subgroup_children[item_subgroup.name] = {}
  --   table.insert(data.raw['item-group'][item_subgroup.group].subgroups, item_subgroup)
  -- end

  -- for _, item in pairs(data.raw['item']) do
  --   table.insert(subgroup_children[item.subgroup or 'other'], item)
  -- end
  -- for _, fluid in pairs(data.raw['fluid']) do
  --   table.insert(subgroup_children[fluid.subgroup or 'fluid'], fluid)
  -- end
  -- for _, signal in pairs(data.raw['virtual-signal']) do
  --   table.insert(subgroup_children[signal.subgroup or 'virtual-signal'], signal)
  -- end

  -- local slot = 1

  -- for _, item_group in pairs(data.raw['item-group']) do
  --   local slot_was = slot
  --   for _, item_subgroup in ipairs(item_group.subgroups) do
  --     local children = subgroup_children[item_subgroup.name]
  --     for _, child in ipairs(children) do
  --       local signal_type = child.type
  --       if signal_type == 'virtual-signal' then signal_type = 'virtual' end
  --       if signal_type == 'item' and child.flags and table_contains(child.flags, 'hidden') then
  --         -- nothing
  --       elseif signal_type == 'fluid' and child.hidden then
  --         -- nothing
  --       -- elseif signal_type == 'virtual' and child.special then
  --         -- nothing
  --       else
  --         slot = slot + 1
  --       end
  --     end
  --     slot = next_10(slot-1) + 1
  --   end

  --   -- skip adding a row between groups if none if its sub groups added anything
  --   if slot > slot_was then
  --     slot = next_10(slot) + 1
  --   end
  -- end

  -- log('estimate_required_combinator_slots: ' .. slot)
  -- return next_10(slot) + 150 -- a buffer of some rows in case other mods do wanky shit on data-final-fixes too :o

  return 2000 -- guess off by just 4 rows from k2se
end

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
combinator.item_slot_count = estimate_required_combinator_slots()
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
