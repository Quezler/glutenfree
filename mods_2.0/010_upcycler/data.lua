local function replace_recipe_ingredient(recipe, from_name, to_name)
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.name == from_name then
      ingredient.name = to_name
    end
  end
end

local upcycler_entity = table.deepcopy(data.raw["furnace"]["recycler"])
local upcycler_item   = table.deepcopy(data.raw["item"   ]["recycler"])

upcycler_item.name = "upcycler"
upcycler_entity.name = upcycler_item.name

upcycler_item.icon = "__upcycler__/graphics/icons/upcycler.png"
upcycler_entity.icon = "__upcycler__/graphics/icons/upcycler.png"

upcycler_entity.minable.result = upcycler_item.name
upcycler_item.place_result = upcycler_entity.name

data:extend{upcycler_entity, upcycler_item}

data.raw["technology"]["quality-module"].icon = "__upcycler__/graphics/technology/upcycling.png"
data.raw["technology"]["quality-module-2"].hidden = true
data.raw["technology"]["quality-module-3"].hidden = true

local upcycler_recipe = table.deepcopy(data.raw["recipe"]["recycler"])
upcycler_recipe.name = upcycler_item.name
upcycler_recipe.results[1].name = upcycler_item.name
upcycler_recipe.surface_conditions = nil
replace_recipe_ingredient(upcycler_recipe, "processing-unit", "advanced-circuit")
replace_recipe_ingredient(upcycler_recipe, "concrete", "stone-brick")
data:extend{upcycler_recipe}

table.insert(data.raw["technology"]["quality-module"].effects, 1, {type = "unlock-recipe", recipe = upcycler_recipe.name})

upcycler_entity.graphics_set.animation.north.layers[1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-N.png"
upcycler_entity.graphics_set.animation.east.layers [1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-E.png"
upcycler_entity.graphics_set.animation.south.layers[1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-S.png"
upcycler_entity.graphics_set.animation.west.layers [1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-W.png"

upcycler_entity.graphics_set_flipped.animation.north.layers[1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-flipped-N.png"
upcycler_entity.graphics_set_flipped.animation.east.layers [1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-flipped-E.png"
upcycler_entity.graphics_set_flipped.animation.south.layers[1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-flipped-S.png"
upcycler_entity.graphics_set_flipped.animation.west.layers [1].filename = "__upcycler__/graphics/entity/upcycler/upcycler-flipped-W.png"
