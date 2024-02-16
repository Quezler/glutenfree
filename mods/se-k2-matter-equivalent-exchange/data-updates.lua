local data_util = require("__space-exploration__.data_util")

-- data.raw['recipe']['se-kr-basic-stabilizer'].hidden = true
-- data.raw['recipe']['se-kr-charge-basic-stabilizer'].hidden = true

-- this apparently doesn't exist upstream? (written @ 0.6.125)
-- function data_util.remove_result(recipe, name)
--   if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
--   if not recipe then return end
--   if recipe.results then
--     data_util.remove_result_sub(recipe, name)
--   end
--   if recipe.normal and recipe.normal.results then
--     data_util.remove_result_sub(recipe.normal, name)
--   end
--   if recipe.expensive and recipe.expensive.results then
--     data_util.remove_result_sub(recipe.expensive, name)
--   end
-- end

-- local function remove_basic_stabilizer(recipe_name)
--   data_util.remove_ingredient(recipe_name, "se-kr-charged-basic-stabilizer")
--   data_util.remove_result(recipe_name, "se-kr-charged-basic-stabilizer")
--   data_util.remove_result(recipe_name, "se-kr-basic-stabilizer")
-- end

-- remove_basic_stabilizer("matter-to-stone")
-- remove_basic_stabilizer("matter-to-sand")
-- remove_basic_stabilizer("matter-to-coal")
-- remove_basic_stabilizer("matter-to-copper-ore")
-- remove_basic_stabilizer("matter-to-iron-ore")
-- remove_basic_stabilizer("matter-to-crude-oil")
-- remove_basic_stabilizer("matter-to-raw-rare-metals")
-- remove_basic_stabilizer("matter-to-uranium-ore")
-- remove_basic_stabilizer("matter-to-uranium-238")
-- remove_basic_stabilizer("matter-to-water")
-- remove_basic_stabilizer("matter-to-mineral-water")

for _, recipe in pairs(data.raw.recipe) do
  if recipe.subgroup == "matter-deconversion" then
    -- log(recipe.name)
    if recipe.ingredients then
      for _, ingredient in pairs(recipe.ingredients) do
        if ingredient.name == "matter" then
          ingredient.amount = ingredient.amount / 2
          if ingredient.catalyst_amount then
            ingredient.catalyst_amount = ingredient.catalyst_amount / 2
          end
        end
      end
    end
    if recipe.normal then
      for _, ingredient in pairs(recipe.normal.ingredients) do
        if ingredient.name == "matter" then
          ingredient.amount = ingredient.amount / 2
          if ingredient.catalyst_amount then
            ingredient.catalyst_amount = ingredient.catalyst_amount / 2
          end
        end
      end      
    end
    if recipe.expensive then
      for _, ingredient in pairs(recipe.expensive.ingredients) do
        if ingredient.name == "matter" then
          ingredient.amount = ingredient.amount / 2
          if ingredient.catalyst_amount then
            ingredient.catalyst_amount = ingredient.catalyst_amount / 2
          end
        end
      end
    end
  end
end

local function opposite(recipe_name)
  local left, right = recipe_name:match("(.+)%-to%-(.+)")
  return right .. '-to-' .. left
end

for _, recipe in pairs(data.raw.recipe) do
  -- if recipe.subgroup == "matter-deconversion" then
  --   log(recipe.name)
  --   log(opposite(recipe.name))
  -- end
  if recipe.subgroup == "matter-conversion" then
    log(recipe.name)
    local opposite_recipe = data.raw['recipe'][opposite(recipe.name)]
    log(opposite_recipe ~= nil)
  end
end


-- remove the recipe from techs by enabling it fully and then disabeling it completely

-- data_util.enable_recipe('se-kr-basic-stabilizer')
-- data_util.disable_recipe('se-kr-basic-stabilizer')

-- data_util.enable_recipe('se-kr-charge-basic-stabilizer')
-- data_util.disable_recipe('se-kr-charge-basic-stabilizer')

-- makes sense, but it makes the technology items look weird
-- data_util.recipe_require_tech("kr-stabilizer-charging-station", "se-kr-advanced-matter-processing")

-- se-vulcanite-to-matter
-- matter-to-se-vulcanute

local function make_matter_match(conversion, deconversion)
  if type(conversion) == "string" then conversion = data.raw.recipe[conversion] end
  if type(deconversion) == "string" then deconversion = data.raw.recipe[deconversion] end

  assert(conversion.normal == nil)
  assert(conversion.deconversion == nil)
  assert(deconversion.normal == nil)
  assert(deconversion.deconversion == nil)

  for _, result in ipairs(conversion.results) do
    if result.name == "matter" then
      for _, ingredient in ipairs(deconversion.ingredients) do
        if ingredient.name == "matter" then
          ingredient.amount = result.amount
          return
        end
      end
    end
  end

  error()
end

make_matter_match('se-vulcanite-to-matter', 'matter-to-se-vulcanute')
make_matter_match('se-cryonite-to-matter', 'matter-to-se-cryonite')
make_matter_match('se-beryllium-ore-to-matter', 'matter-to-se-beryllium-ore')
make_matter_match('se-holmium-ore-to-matter', 'matter-to-se-holmium-ore')
make_matter_match('se-iridium-ore-to-matter', 'matter-to-se-iridium-ore')
make_matter_match('raw-imersite-to-matter', 'matter-to-raw-imersite')
