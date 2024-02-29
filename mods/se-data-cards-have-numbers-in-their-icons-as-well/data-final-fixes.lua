local data_util = require("__space-exploration__.data_util")

local function numberize_prototype(prototype, number)
  if prototype.icon == nil then return end
  assert(prototype.icon ~= nil)
  assert(prototype.icons == nil)
  prototype.icons = data_util.sub_icons(prototype.icon,
  { icon = "__space-exploration-graphics__/graphics/icons/number/".. number .. ".png", scale = 0.5, icon_size = 20 })

  prototype.icon = nil
  prototype.icon_size = nil
end

local function handle_ingredient(ingredient, number)
  local item_name = ingredient.name or ingredient[1]
  log(item_name)
  if string.match(item_name, "-data$") then
    numberize_prototype(data.raw['item'][item_name], number)
    local recipe = data.raw['recipe'][item_name]
    if recipe then numberize_prototype(recipe, number) end
  end
end

for _, recipe in pairs(data.raw['recipe']) do
  if string.match(recipe.name, "^se-") and string.find(recipe.name, '-catalogue-') then
    local number = string.sub(recipe.name, -1)
    log(string.format('%s = %d', recipe.name, number))

    log(serpent.block( recipe.ingredients ))
    for _, ingredient in ipairs(recipe.ingredients) do
      handle_ingredient(ingredient, number)
    end

    -- assert(recipe.icons == nil)
    -- recipe.icons = data_util.sub_icons(recipe.icon,
    -- { icon = "__space-exploration-graphics__/graphics/icons/number/".. number .. ".png", scale = 0.5, icon_size = 20 })
    -- recipe.icon = nil
    -- recipe.icon_size = nil
  end
end

-- error('dah')
