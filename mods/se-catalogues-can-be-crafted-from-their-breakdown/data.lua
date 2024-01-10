local function get_recipe_results(recipe)
  if recipe.results then return recipe.results end

  if recipe.normal then return get_recipe_results(recipe.normal) end

  return {{type = "item", name = recipe.result, amount = recipe.result_count or 1}}
end

local function get_full_recipe_results(recipe)
  local results = get_recipe_results(recipe)
  for i, result in pairs(results) do
    if result[1] and result[2] then
      results[i] = {type = "item", name = result[1], amount = result[2]}
    end
    result.type = result.type or "item"
  end

  return results
end

-- log(serpent.block(data.raw['recipe']))
-- error()

local recipes_for = {}
for _, recipe in pairs(data.raw['recipe']) do
  -- log(recipe.name)
  for _, result in pairs(get_full_recipe_results(recipe)) do
    if result.type == "item" or result.type == nil then
      -- log(recipe.name .. serpent.line(result))
      -- log(serpent.block(recipe))
      -- log(serpent.block(result))
      recipes_for[result.name] = recipes_for[result.name] or {}
      recipes_for[result.name][recipe.name] = true
    end
  end
end

log(serpent.block(recipes_for))
error()

local function handle_catalogue(item_name)
  log(serpent.block(data.raw['recipe']['item-name']))
  error()
end

for _, item in pairs(data.raw['item']) do
  if string.match(item.name, "-catalogue-") then
    log(item.name)
  end
end

handle_catalogue('se-astronomic-catalogue-1')

-- se-astronomic-catalogue-1
-- se-astronomic-catalogue-2
-- se-astronomic-catalogue-3
-- se-astronomic-catalogue-4
-- se-biological-catalogue-1
-- se-biological-catalogue-2
-- se-biological-catalogue-3
-- se-biological-catalogue-4
-- se-energy-catalogue-1
-- se-energy-catalogue-2
-- se-energy-catalogue-3
-- se-energy-catalogue-4
-- se-material-catalogue-1
-- se-material-catalogue-2
-- se-material-catalogue-3
-- se-material-catalogue-4
-- se-deep-catalogue-1
-- se-deep-catalogue-2
-- se-deep-catalogue-3
-- se-deep-catalogue-4
-- se-kr-matter-catalogue-1
-- se-kr-matter-catalogue-2

-- error()
