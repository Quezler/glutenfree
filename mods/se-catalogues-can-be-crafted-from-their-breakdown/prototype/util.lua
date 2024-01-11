local prototype_util = {}

function prototype_util.get_recipe_results(recipe)
  if recipe.results then return recipe.results end

  if recipe.normal then return prototype_util.get_recipe_results(recipe.normal) end
  -- lets just say that expensive mode is currently not supported :)

  return {{type = "item", name = recipe.result, amount = recipe.result_count or 1}}
end

function prototype_util.get_full_recipe_results(recipe)
  local results = prototype_util.get_recipe_results(recipe)
  for i, result in pairs(results) do
    if result[1] and result[2] then
      results[i] = {type = "item", name = result[1], amount = result[2]}
    end
    result.type = result.type or "item"
  end

  return results
end

function prototype_util.unlock_recipe_alongside(new_recipe, old_recipe)
  for i, technology in pairs(data.raw['technology']) do
    for j, effect in ipairs(technology.effects or {}) do
      if effect.type == "unlock-recipe" then
        if effect.recipe == old_recipe then
          table.insert(technology.effects, j+1, {type = "unlock-recipe", recipe = new_recipe})
          goto next_technology
        end
      end
    end
    ::next_technology::
  end
end

return prototype_util
