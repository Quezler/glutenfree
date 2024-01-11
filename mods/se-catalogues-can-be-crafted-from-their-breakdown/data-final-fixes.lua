local prototype_util = require('prototype.util')

--

local function ends_with(str, ending)
  return str:sub(-#ending) == ending
end

local function recipe_is_annoying(item_name)
  if item_name == 'se-astrometric-data' then return false end

  if ends_with(item_name, '-data') then return true end
end

--

local recipes_for = {}
for _, recipe in pairs(data.raw['recipe']) do
  for _, result in pairs(prototype_util.get_full_recipe_results(recipe)) do
    if result.type == "item" then
      recipes_for[result.name] = recipes_for[result.name] or {}
      table.insert(recipes_for[result.name], recipe.name)
    end
  end
end

-- log(serpent.block(recipes_for))
-- error()

local function handle_catalogue(item_name)
  local recipe = data.raw['recipe'][item_name] -- assume the catalogue has the same recipe name as the item

  assert(recipe)
  assert(recipe.normal == nil)
  assert(recipe.expensive == nil)

  local clone = table.deepcopy(recipe)
  clone.localised_name = {"", {"item-name." .. clone.name}, " shortcut"}
  clone.name = clone.name .. '-shortcut'

  do -- lazy bastard-ify the icon
    if clone.icon == nil and clone.icons == nil then
      clone.icons = table.deepcopy(data.raw['item'][item_name].icons)
    end

    if clone.icons == nil then
      clone.icons = {{icon = clone.icon, icon_size = clone.icon_size}}
    end

    clone.icon = nil
    clone.icon_size = nil

    for _, icondata in ipairs(clone.icons) do
      assert(icondata.scale == nil) -- when this gets triggered, remove it and check the 0.3 scale code below works for it
      icondata.scale = (icondata.scale or 1) * 0.3
    end

    table.insert(clone.icons, 1, {icon = "__base__/graphics/achievement/lazy-bastard.png", icon_size = 128, scale = 0.25})
  end

  clone.order = string.sub(data.raw['item'][item_name].order, 2):gsub("^", "b") -- a-1 -> b-1

  -- for _, ingredient in pairs(clone.ingredients) do
  --   if (ingredient.type or "item") == "item" then
  --     clone.ing
  --   end
  -- end

  -- remove item ingredients from the clone
  for i = #clone.ingredients, 1, -1 do
    if clone.ingredients[i].type == nil or clone.ingredients[i].type == "item" then
      table.remove(clone.ingredients, i)
    end
  end

  data:extend{clone}

  prototype_util.unlock_recipe_alongside(clone.name, recipe.name)

  if item_name ~= "se-astronomic-catalogue-1" then return end
  log(serpent.block(recipe))

  for _, ingredient in ipairs(recipe.ingredients) do
    -- log(serpent.block(ingredient))
    if recipe_is_annoying(ingredient.name) then
      if #recipes_for[ingredient.name] ~= 1 then
        error(string.format('\nmultiple recipes possible for "%s": %s', ingredient.name, serpent.block(recipes_for[ingredient.name])))
      end

      local ingredient_recipe = data.raw['recipe'][ingredient.name]
      
      log(serpent.block( ingredient_recipe ))
    end
  end

  -- table.insert(clone.results, {
  --   amount = 20,
  --   name = "water",
  --   type = "fluid"
  -- })

  -- table.insert(clone.results, {
  --   amount = 20,
  --   name = "lubricant",
  --   type = "fluid"
  -- })

  -- error()
end

for _, item in pairs(data.raw['item']) do
  if string.match(item.name, "-catalogue-") then
    log(item.name)
    handle_catalogue(item.name)
  end
end

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
