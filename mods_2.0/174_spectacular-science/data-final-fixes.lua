local function handle_recipe(recipe)
  if recipe.hidden then return end
  if recipe.parameter then return end
  if recipe.enabled == false then return end

  log(recipe.name)
end

for _, recipe in pairs(data.raw["recipe"]) do
  -- if recipe.enabled == nil or recipe.enabled == true then
  --   if recipe.hidden == nil or recipe.hidden == false then
  --     if recipe.parameter == nil then
  --       log(recipe.name)
  --     end
  --   end
  -- end
  -- if recipe.enabled == true then
  --   log(recipe.name)
  -- end
  handle_recipe(recipe)
end

local technology_name_to_recipe_names = {}
for _, technology in pairs(data.raw["technology"]) do
  technology_name_to_recipe_names[technology.name] = {}
  for _, effect in pairs(technology.effects or {}) do
    if effect.type == "unlock-recipe" then
      technology_name_to_recipe_names[technology.name][effect.recipe] = true
    end
  end
end

log(serpent.block(technology_name_to_recipe_names))
