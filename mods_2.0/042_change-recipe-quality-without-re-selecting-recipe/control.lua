local mod_prefix = "change-recipe-quality-without-re-selecting-recipe-"

local next_quality = {}
local previous_quality = {}

-- crude, does not care about a quality having two previouses
for _, quality in pairs(prototypes.quality) do
  if quality.next then
    next_quality[quality.name] = quality.next.name
    previous_quality[quality.next.name] = quality.name
  end
end

local recipe_has_item_ingredients = {}
for _, recipe in pairs(prototypes.recipe) do
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == "item" then
      recipe_has_item_ingredients[recipe.name] = true
      goto continue
    end
  end
  ::continue::
end

local function assembler_set_recipe_and_quality(assembler, recipe, quality)
  if assembler.force.is_quality_unlocked(quality) == false then return end

  local items = assembler.set_recipe(recipe, quality)
  if items[1] == nil then return end

  for _, item in ipairs(items) do
    assembler.surface.spill_item_stack{
      position = assembler.position,
      stack = item,
      force = assembler.force,
      allow_belts = false,
    }
  end
end

local function try_change_quality(assembler, increment_quality)
  local recipe_prototype, quality_prototype = assembler.get_recipe()
  if not recipe_has_item_ingredients[recipe_prototype.name] then return end

  if increment_quality then
    if next_quality[quality_prototype.name] then
      -- game.print(string.format("changing from %s to %s.", quality_prototype.name, next_quality[quality_prototype.name]))
      assembler_set_recipe_and_quality(assembler, recipe_prototype, next_quality[quality_prototype.name])
    end
  else
    if previous_quality[quality_prototype.name] then
      -- game.print(string.format("changing from %s to %s.", quality_prototype.name, previous_quality[quality_prototype.name]))
      assembler_set_recipe_and_quality(assembler, recipe_prototype, previous_quality[quality_prototype.name])
    end
  end
end

local function entity_is_assembling_machine(entity)
  return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

local function on_custom_input(event)
  local prototype = event.selected_prototype
  if prototype == nil then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  if prototype.derived_type == "recipe" then
    local opened = player.opened
    if opened and player.opened_gui_type == defines.gui_type.entity and entity_is_assembling_machine(opened) then
      local recipe = opened.get_recipe()
      if recipe and recipe.name == prototype.name then
        try_change_quality(opened, event.input_name == mod_prefix .. "cycle-quality-up")
      end
    end
  end

  if prototype.derived_type == "assembling-machine" then
    local selected = player.selected
    if selected and entity_is_assembling_machine(selected) then
      local recipe = selected.get_recipe()
      if recipe then
        try_change_quality(selected, event.input_name == mod_prefix .. "cycle-quality-up")
      end
    end
  end

  if prototype.derived_type == "entity-ghost" then
    local selected = player.selected
    if selected and entity_is_assembling_machine(selected) then
      local recipe = selected.get_recipe()
      if recipe then
        try_change_quality(selected, event.input_name == mod_prefix .. "cycle-quality-up")
      end
    end
  end

  -- game.print(serpent.line(event))
end

script.on_event(mod_prefix .. "cycle-quality-up", on_custom_input)
script.on_event(mod_prefix .. "cycle-quality-down", on_custom_input)
