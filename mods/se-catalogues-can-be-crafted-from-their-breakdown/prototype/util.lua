local prototype_util = {}

function prototype_util.get_recipe_results(recipe)
  if recipe.results then return recipe.results end

  -- lets just say that expensive mode is currently not supported :)
  if recipe.normal then return prototype_util.get_recipe_results(recipe.normal) end

  return {{type = "item", name = recipe.result, amount = recipe.result_count or 1}}
end

function prototype_util.get_full_recipe_results(recipe)
  local results = prototype_util.get_recipe_results(recipe)
  for i, result in pairs(results) do
    if result[1] and result[2] then
      results[i] = {type = "item", name = result[1], amount = result[2]}
    end
    result.type = result.type or "item"
    result.probability = result.probability or 1
  end

  return results
end

function prototype_util.get_recipe_ingredients(recipe)
  if recipe.ingredients then return recipe.ingredients end

  -- lets just say that expensive mode is currently not supported :)
  if recipe.normal then return prototype_util.get_recipe_ingredients(recipe.normal) end

  error('is this possible?')
end

function prototype_util.get_full_recipe_ingredients(recipe)
  local ingredients = prototype_util.get_recipe_ingredients(recipe)
  for i, ingredient in pairs(ingredients) do
    if ingredient[1] and ingredient[2] then
      ingredients[i] = {type = "item", name = ingredient[1], amount = ingredient[2]}
    end
    ingredient.type = ingredient.type or "item"
  end

  return ingredient
end

function prototype_util.normalize_recipe(recipe)
  prototype_util.get_full_recipe_results(recipe)
  prototype_util.get_full_recipe_ingredients(recipe)
  return recipe
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

function prototype_util.add_ingredient_to_recipe(new_ingredient, recipe)
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == new_ingredient.type and ingredient.name == new_ingredient.name then
      ingredient.amount = ingredient.amount + ingredient.amount
      return
    end
  end
  table.insert(recipe.ingredients, new_ingredient)
end

return prototype_util
