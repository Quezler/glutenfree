local function find_ingredient(recipe_prototype, ingredient_name)
  for _, ingredient in ipairs(recipe_prototype.ingredients) do
    if ingredient.name == ingredient_name then
      return ingredient
    end
  end

  error(string.format('recipe %s has no %s ingredient.', recipe_prototype.name, ingredient_name))
end

local stabilizers = {
  ['se-kr-basic-stabilizer'] = true,
  ['se-kr-charged-basic-stabilizer'] = true,
  ['se-kr-stabilizer'] = true,
  ['se-kr-charged-stabilizer'] = true,
}

local function find_non_stabilizer_product(recipe_prototype)
  for _, product in ipairs(recipe_prototype.products) do
    if stabilizers[product.name] == nil then
      return product
    end
  end

  log(serpent.block(recipe_prototype.products))
  error(string.format('recipe %s has no non-stabilizer product.', recipe_prototype.name))
end

local skip = {
  ['charged-antimatter-fuel-cell'] = true,
}

local function check(event)
  local recipe_prototypes = game.get_filtered_recipe_prototypes({
    {filter = 'category', category = 'matter-deconversion'},
    {filter = 'category', category = 'matter-conversion'},
  })

  local deconversion = {}
  local conversion = {}

  for _, recipe_prototype in pairs(recipe_prototypes) do

    if skip[recipe_prototype.name] == nil then
      if recipe_prototype.category == 'matter-deconversion' then
        find_ingredient(recipe_prototype, 'matter')
        deconversion[find_non_stabilizer_product(recipe_prototype).name] = find_ingredient(recipe_prototype, 'matter').amount
        -- log(serpent.block(recipe_prototype.products))
      end
    end
  end

  log(serpent.block(deconversion))
  log(serpent.block(conversion))
end

script.on_init(check)
script.on_configuration_changed(check)
