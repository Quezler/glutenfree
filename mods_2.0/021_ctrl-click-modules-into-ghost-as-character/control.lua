local module_inventory_for_type = {
  ["furnace"           ] = defines.inventory.furnace_modules,            -- 4
  ["assembling-machine"] = defines.inventory.assembling_machine_modules, -- 4
  ["lab"               ] = defines.inventory.lab_modules,                -- 3
  ["mining-drill"      ] = defines.inventory.mining_drill_modules,       -- 2
  ["rocket-silo"       ] = defines.inventory.rocket_silo_modules,        -- 4
  ["beacon"            ] = defines.inventory.beacon_modules,             -- 1
}

local module_inventory_size = {}
for _, entity_prototype in pairs(prototypes.entity) do
  module_inventory_size[entity_prototype.name] = entity_prototype.module_inventory_size
end

local is_module = {}
for _, item_prototype in pairs(prototypes.item) do
  if item_prototype.type == "module" then
    is_module[item_prototype.name] = true
  end
end

local function is_player_holding_module(player)
  if player.cursor_ghost then
    return is_module[player.cursor_ghost.name.name], player.cursor_ghost.name.name, player.cursor_ghost.quality.name
  end

  if player.cursor_stack.valid_for_read then
    return is_module[player.cursor_stack.prototype.name], player.cursor_stack.prototype.name, player.cursor_stack.quality.name
  end
end

-- lua equivalent of ModulePrototype::isUpgradeTo
local function is_upgrade_to(this_name, this_quality, other_name, other_quality)
  local this_prototype = prototypes.item[this_name]
  local other_prototype = prototypes.item[other_name]

  if this_prototype.category ~= other_prototype.category then return false end

  if this_prototype.tier ~= other_prototype.tier then
    return this_prototype.tier > other_prototype.tier
  end

  local this_quality = prototypes.quality[this_quality]
  local other_quality = prototypes.quality[other_quality]

  if this_quality.level ~= other_quality.level then
    return this_quality.level > other_quality.level
  end

  return false
end

local function insert_plan_add_module(entity, inventory_index, slot, module_name, module_quality)
  local insert_plan = entity.insert_plan
  local stack = slot - 1
  local blueprint_insert_plan_with_matching_id = nil

  for _, blueprint_insert_plan in ipairs(insert_plan) do
    local quality_name = blueprint_insert_plan.id.quality and blueprint_insert_plan.id.quality.name or "normal"
    if blueprint_insert_plan.id.name == module_name and quality_name == module_quality then
      blueprint_insert_plan_with_matching_id = blueprint_insert_plan
    end

    for _, inventory_position in ipairs(blueprint_insert_plan.items.in_inventory) do
      -- there is already a module request for this slot
      if inventory_position.inventory == inventory_index and inventory_position.stack == stack then
        -- the new module is not an upgrade of the module that is already occuping this slot
        if is_upgrade_to(module_name, module_quality, blueprint_insert_plan.id.name, quality_name) == false then
          return false
        end
      end
    end
  end

  local inventory_position = {
    inventory = inventory_index,
    stack = stack,
  }

  if blueprint_insert_plan_with_matching_id then
    table.insert(blueprint_insert_plan_with_matching_id.items.in_inventory, inventory_position)
    entity.insert_plan = insert_plan
  else
    table.insert(insert_plan, {
      id = {name = module_name, quality = module_quality},
      items = {in_inventory = {inventory_position}},
    })
    entity.insert_plan = insert_plan
  end
end

script.on_event("ctrl-click-modules-into-ghost-as-character", function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  if player.controller_type ~= defines.controllers.character then return end

  local ghost = player.selected
  if ghost == nil then return end
  if ghost.type ~= "entity-ghost" then return end

  local inventory_index = module_inventory_for_type[ghost.ghost_type]
  if inventory_index == nil then return end -- ghost not of an entity that supports module slots

  local module_slots = module_inventory_size[ghost.ghost_name]
  if module_slots == 0 then return end

  local holding_module, module_name, module_quality = is_player_holding_module(player)
  if holding_module ~= true then return end

  -- todo: check if machine/recipe supports this module type

  for slot = 1, module_slots do
    insert_plan_add_module(ghost, inventory_index, slot, module_name, module_quality)
  end
end)
