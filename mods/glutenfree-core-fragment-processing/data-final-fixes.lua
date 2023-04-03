local gluten = 'se-core-fragment-omni'

-- removes one instance of gluten from the output
local function remove_gluten_from_recipe(recipe)
  for i, result in ipairs(recipe.results) do
    if result.name == gluten then
      table.remove(recipe.results, i)

      if #recipe.results == 1 then -- stone
        recipe.always_show_products = true
      end

      return true
    end
  end

  return false
end

for _, recipe in pairs(data.raw['recipe']) do
  if recipe.category == "core-fragment-processing" then
    if remove_gluten_from_recipe(recipe) then
      print("✔ removed " .. gluten .. " from " .. recipe.name)
    else
      print("✘ removed " .. gluten .. " from " .. recipe.name)
    end
  end
end
