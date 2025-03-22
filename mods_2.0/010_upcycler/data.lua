require("util")

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
if settings.startup["upcycling-no-quality-modules"].value then
  data.raw["technology"]["quality-module-2"].hidden = true
  data.raw["technology"]["quality-module-3"].hidden = true
end

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

upcycler_entity.module_slots = 0
upcycler_entity.allowed_effects = {}
-- upcycler_entity.source_inventory_size = 1

data:extend{{
  type = "recipe-category",
  name = "upcycling",
}}
upcycler_entity.crafting_categories = {"upcycling"}
upcycler_entity.energy_source = {type = "void"}

-- can't get this to work
-- upcycler_entity.graphics_set.working_visualisations.idle_animation = upcycler_entity.graphics_set.animation
-- upcycler_entity.graphics_set.working_visualisations.always_draw_idle_animation = true

upcycler_entity.return_ingredients_on_change = false

data:extend{{
  type = "item",
  name = "upcycle-any-quality",
  icon = "__core__/graphics/icons/any-quality.png",
  stack_size = 1,

  hidden = true,
  hidden_in_factoriopedia = true,
}}

data:extend{{
  type = "recipe",
  name = "upcycling",
  category = "upcycling",
  icon = util.empty_sprite().filename,
  energy_required = 1 * hour * 24 * 365,

  ingredients = {
    {type = "item", name = "upcycle-any-quality", amount = 1}
  },
  results = {
    {type = "item", name = "upcycle-any-quality", amount = 1}
  },

  auto_recycle = false,
  hidden_in_factoriopedia = true,
  hide_from_player_crafting = true,
}}

data:extend{{
  type = "recipe",
  name = "upcycling-output-slots",
  category = "upcycling",
  icon = util.empty_sprite().filename,
  energy_required = 1 * hour * 24 * 365,

  ingredients = {
    {type = "item", name = "upcycle-any-quality", amount = 1}
  },
  results = {
    -- {type = "item", name = "upcycle-any-quality", amount = 1}
  },

  auto_recycle = false,
  hidden_in_factoriopedia = true,
  hide_from_player_crafting = true,
}}

upcycler_entity.custom_input_slot_tooltip_key = "upcycler-input-slot-tooltip"
upcycler_entity.cant_insert_at_source_message_key = "inventory-restriction.cant-be-upcycled-by-hand"

 -- disable large smoke, keep the small smoke
table.remove(upcycler_entity.graphics_set.working_visualisations, 2)
table.remove(upcycler_entity.graphics_set_flipped.working_visualisations, 2)

local upcycler_input = table.deepcopy(data.raw["linked-container"]["linked-chest"])
upcycler_input.name = "upcycler-input"
upcycler_input.collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
upcycler_input.collision_mask = {layers = {}}
upcycler_input.picture = util.empty_sprite()
upcycler_input.inventory_size = 1
upcycler_input.inventory_type = "normal"
upcycler_input.gui_mode = "none"
upcycler_input.selectable_in_game = false
upcycler_input.quality_indicator_scale = 0
data:extend{upcycler_input}

table.insert(upcycler_entity.flags, "no-automated-item-insertion")
table.insert(upcycler_entity.flags, "no-automated-item-removal")

data:extend{{
  type = "planet",
  name = "upcycler",
  icon = upcycler_entity.icon,

  distance = 0,
  orientation = 0,

  hidden = true,
}}
