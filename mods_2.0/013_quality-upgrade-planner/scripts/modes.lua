local module_names = {}
for _, item_prototype in pairs(prototypes.item) do
  if item_prototype.type == "module" then
    table.insert(module_names, item_prototype.name)
  end
end

local function mode_entities(event, playerdata)
  local inventory = game.create_inventory(1)
  inventory[1].set_stack({name = "upgrade-planner"})
  local upgrade_planner = inventory[1]

  local map = {}
  for i, entity in ipairs(event.entities) do
    map[(entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype).name] = event.quality
  end

  local i = 0
  for entity_name, quality_name in pairs(map) do
    i = i + 1
    upgrade_planner.set_mapper(i, "from", {type = "entity", name = entity_name})
    upgrade_planner.set_mapper(i, "to"  , {type = "entity", name = entity_name, quality = quality_name})
  end

  event.surface.upgrade_area{
    area = event.area,
    force = playerdata.player.force,
    player = playerdata.player,
    skip_fog_of_war = true,
    item = upgrade_planner,
  }

  inventory.destroy()
end

local filter_support_for_entity_type = { -- drills, asteroid collectors & storage chests have filters too, but it makes little sense to touch them.
  ["inserter"] = true,
  ["loader"] = true,

  ["splitter"] = true,
  ["lane-splitter"] = true,
}

local type_is_a_splitter = {
  ["splitter"] = true,
  ["lane-splitter"] = true,
}

local function mode_filters(event, playerdata)

  for _, entity in ipairs(event.entities) do
    if filter_support_for_entity_type[entity.type] then
      for i = 1, entity.filter_slot_count do
        local filter = entity.get_filter(i)
        if filter then
          filter.quality = event.quality
          entity.set_filter(i, filter)
        end
      end

      if type_is_a_splitter[entity.type] then
        local filter = entity.splitter_filter
        if filter then
          filter.quality = event.quality
          entity.splitter_filter = filter
        end
      end
    end
  end
end

local is_assembling_machine = {
  ["assembling-machine"] = true,
  ["rocket-silo"] = true,
}

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

local function mode_recipes(event, playerdata)
  for _, entity in ipairs(event.entities) do
    if is_assembling_machine[entity.type] then
      local recipe, quality = entity.get_recipe()
      if recipe and recipe_has_item_ingredients[recipe.name] and entity.prototype.fixed_recipe == nil then
        local items = entity.set_recipe(recipe, event.quality)
        for _, item in ipairs(items or {}) do
          entity.surface.spill_item_stack{
            position = entity.position,
            stack = item,
            force = entity.force,
            allow_belts = false,
          }
        end
      end
    end
  end
end

local function mode_modules(event, playerdata)
  local inventory = game.create_inventory(1)
  inventory[1].set_stack({name = "upgrade-planner"})
  local upgrade_planner = inventory[1]

  for i, module_name in pairs(module_names) do
    upgrade_planner.set_mapper(i, "from", {type = "item", name = module_name})
    upgrade_planner.set_mapper(i, "to"  , {type = "item", name = module_name, quality = event.quality})
  end

  event.surface.upgrade_area{
    area = event.area,
    force = playerdata.player.force,
    player = playerdata.player,
    skip_fog_of_war = true,
    item = upgrade_planner,
  }

  inventory.destroy()
end

local function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

local function get_entity_type(entity)
  return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

function string_starts_with(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

local function set_logistic_sections_quality(logistic_sections, quality_name)
  for _, section in ipairs(logistic_sections.sections) do
    if section.is_manual and section.group == "" then
      for slot, filter in ipairs(section.filters) do
        if filter.value then
          filter.value.quality = quality_name
          local success, message = pcall(section.set_slot, slot, filter)
          if success == false then
            if string_starts_with(message, "Filter conflicts with filter in slot ") then
              section.clear_slot(slot)
            else
              error(message)
            end
          end
        end
      end
    end
  end
end

local function mode_requests(event, playerdata)
  for _, entity in ipairs(event.entities) do
    local logistic_sections = entity.get_logistic_sections()
    if logistic_sections and get_entity_type(entity) ~= "constant-combinator" then
      set_logistic_sections_quality(logistic_sections, event.quality)
    end
  end
end

local function mode_constants(event, playerdata)
  for _, entity in ipairs(event.entities) do
    local logistic_sections = entity.get_logistic_sections()
    if logistic_sections and get_entity_type(entity) == "constant-combinator" then
      set_logistic_sections_quality(logistic_sections, event.quality)
    end
  end
end

-- https://lua-api.factorio.com/latest/classes/LuaGenericOnOffControlBehavior.html
-- at the time of writing the generic control behavior page does not list all its children neatly,
-- and instead of parsing the runtime-api.json programatically i'll just take this ugly shortcut for now.
local function probe_for_generic_on_off_control_behavior(control_behavior)
  local foo = control_behavior.circuit_condition
  local bar = control_behavior.logistic_condition
end

local extends_generic_on_off_control_behavior = {}
local function get_extends_generic_on_off_control_behavior(control_behavior)
  if extends_generic_on_off_control_behavior[control_behavior.type] == nil then
    local success, message = pcall(probe_for_generic_on_off_control_behavior, control_behavior)
    extends_generic_on_off_control_behavior[control_behavior.type] = success
    if success == false then
      log(message) -- just in case its something totally unexpected
    end
  end

  -- game.print(serpent.line(extends_generic_on_off_control_behavior))
  return extends_generic_on_off_control_behavior[control_behavior.type]
end

local function mode_conditions(event, playerdata)
  for _, entity in ipairs(event.entities) do
    local control_behavior = entity.get_control_behavior()
    if control_behavior and get_extends_generic_on_off_control_behavior(control_behavior) then

      local circuit_condition = control_behavior.circuit_condition
      if circuit_condition.first_signal then
        circuit_condition.first_signal.quality = event.quality
      end
      if circuit_condition.second_signal then
        circuit_condition.second_signal.quality = event.quality
      end
      control_behavior.circuit_condition = circuit_condition

      local logistic_condition = control_behavior.logistic_condition
      if logistic_condition.first_signal then
        logistic_condition.first_signal.quality = event.quality
      end
      if logistic_condition.second_signal then
        logistic_condition.second_signal.quality = event.quality
      end
      control_behavior.logistic_condition = logistic_condition

    end
  end
end

return {
  entities = mode_entities,
  filters = mode_filters,
  recipes = mode_recipes,
  modules = mode_modules,
  requests = mode_requests,
  constants = mode_constants,
  conditions = mode_conditions,
}
