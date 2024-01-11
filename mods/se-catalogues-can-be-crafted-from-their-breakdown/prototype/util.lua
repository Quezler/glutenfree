local prototype_util = {}

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
