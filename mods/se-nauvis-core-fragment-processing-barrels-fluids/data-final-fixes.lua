local function barrel_outputs_for_recipe(recipe)
  assert(recipe.normal == nil)
  assert(recipe.expensive == nil)
  assert(#recipe.ingredients == 1)
  -- log(serpent.block(recipe))
  
  local total_barrels = 0
  local description = {}

  for _, result in ipairs(recipe.results) do
    if result.type and result.type == "fluid" then
      local fill_barrel = data.raw['recipe']['fill-' .. result.name .. '-barrel'] -- crash if unbarrelable, expected
      local per_barrel = fill_barrel.ingredients[1].amount -- expect the first ingredient of the barrel recipe to be the fluid
      assert(per_barrel)
      -- log(serpent.block(fill_barrel))

      local probability = result.amount / per_barrel
      total_barrels = total_barrels + (probability)

      table.insert(description, string.format('[fluid=%s][font=default-bold]%d[/font]', result.name, result.amount))

      result.type = 'item'
      result.name = result.name .. '-barrel'
      result.probability = probability
      result.amount = 1
      assert(1 >= result.probability) -- in case a recipe ever returns more fluid than can fit in sa single barrel
    end
  end

  table.insert(recipe.ingredients, {
    type = 'item',
    name = 'empty-barrel',
    amount = math.ceil(total_barrels),
  })

  table.insert(recipe.results, {
    type = 'item',
    name = 'empty-barrel',
    amount = 1,
    probability = 1 - (total_barrels % 1),
  })

  -- 64 + 32 + 32 + 8 + 64 = 200

  -- log(total_barrels)

  -- log(serpent.block(recipe))
  -- error('foo')

  assert(recipe.localised_description == nil)
  recipe.localised_description = table.concat(description, ' ')
end

barrel_outputs_for_recipe(data.raw['recipe']['se-core-fragment-omni'])
