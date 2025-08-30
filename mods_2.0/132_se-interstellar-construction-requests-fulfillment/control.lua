local mod = {}

local Turret = require("scripts.turret")(mod)

script.on_init(function()
  storage.all_ghosts = {}
  storage.new_ghosts = {}

  storage.all_proxies = {}
  storage.new_proxies = {}

  -- generally there are not a lot of diverse requests so we have an one to many relationship here
  storage.item_to_entities_map = {}

  storage.turrets = {}
  storage.deathrattles = {}
  storage.tasks_at_tick = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = {"entity-ghost", "tile-ghost"}}) do
      mod.add_new_ghost(entity)
    end
    for _, entity in ipairs(surface.find_entities_filtered{name = "item-request-proxy"}) do
      mod.add_new_proxy(entity)
    end
  end
end)

script.on_configuration_changed(function()
  assert(storage.structs == nil and storage.v1_structs == nil, "not compatible with versions below 3.0.0, remove the mod from the save first.")

  -- todo: refresh all requested items since prototype changes could have changed construction materials
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local turret = {
    entity = entity,
    unit_number = entity.unit_number,

    barrel = math.random(0, 3),
  }

  turret.character = entity.surface.create_entity{
    name = "interstellar-construction-character",
    force = entity.force,
    position = entity.position,
  }
  turret.character.destructible = false
  -- fill these character inventories with full stacks to prevent any automatic insertions
  turret.character.get_inventory(defines.inventory.character_armor).insert({"light-armor"})
  turret.character.get_inventory(defines.inventory.character_guns).insert("pistol")
  turret.character.get_inventory(defines.inventory.character_ammo).insert("firearm-magazine")

  storage.turrets[entity.unit_number] = turret
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "turret", unit_number = entity.unit_number}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "interstellar-construction-turret"},
  })
end

mod.add_new_ghost = function(entity)
  local unit_number = entity.unit_number

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "ghost", unit_number = unit_number}
  storage.new_ghosts[unit_number] = true
  storage.all_ghosts[unit_number] = {
    entity = entity,
    unit_number = unit_number,

    item_name_map = {},
  }
end

mod.add_new_proxy = function(entity)
  local unit_number = entity.unit_number

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "proxy", unit_number = unit_number}
  storage.new_proxies[unit_number] = true
  storage.all_proxies[unit_number] = {
    entity = entity,
    unit_number = unit_number,

    item_name_map = {},
  }
end


-- item request proxies will not have any insertion/removal requests on creation,
-- and any other mods might react to any of their events as well,
-- so it is better to process them the next tick.
local on_script_trigger_effect_handlers = {
  ["item-request-proxy-created"] = function(entity) mod.add_new_proxy(entity) end,
  ["entity-ghost-created"] = function(entity) mod.add_new_ghost(entity) end,
  ["tile-ghost-created"] = function(entity) mod.add_new_ghost(entity) end,
}

script.on_event(defines.events.on_script_trigger_effect, function(event)
  local handler = on_script_trigger_effect_handlers[event.effect_id]
  if handler then handler(event.source_entity) end
end)

function mod.insert_into_item_to_entities_map(item_name, struct)
  assert(type(item_name) == "string")
  storage.item_to_entities_map[item_name] = storage.item_to_entities_map[item_name] or {}
  storage.item_to_entities_map[item_name][struct.unit_number] = true
  struct.item_name_map[item_name] = true
end

function mod.remove_from_item_to_entities_map(item_name, struct)
  assert(type(item_name) == "string")
  storage.item_to_entities_map[item_name][struct.unit_number] = nil
  struct.item_name_map[item_name] = nil
end

function mod.process_new()
  for unit_number, _ in pairs(storage.new_ghosts) do
    storage.new_ghosts[unit_number] = nil
    local ghost = storage.all_ghosts[unit_number]
    if ghost.entity.valid then
      local items_to_place_this = ghost.entity.ghost_prototype.items_to_place_this
      if items_to_place_this then
        mod.insert_into_item_to_entities_map(items_to_place_this[1].name, ghost)
      end
    end
  end

  for unit_number, _ in pairs(storage.new_proxies) do
    storage.new_proxies[unit_number] = nil
    local ghost = storage.all_ghosts[unit_number]
  end
end

function mod.process_proxies()
  for unit_number, proxy in pairs(storage.all_proxies) do
    if proxy.entity.valid then
      local old_item_name_map = proxy.item_name_map
      proxy.item_name_map = {}
      for _, blueprint_insert_plan in ipairs(proxy.entity.insert_plan) do
        local item_name = blueprint_insert_plan.id.name -- why not name.name?

        old_item_name_map[item_name] = nil
        mod.insert_into_item_to_entities_map(item_name, proxy)
      end

      -- remove the stale insertion requests
      for item_name,_ in pairs(old_item_name_map) do
        mod.remove_from_item_to_entities_map(item_name, proxy)
      end
    end
  end
end

function mod.clean_item_to_entities_map()
  for item_name, structs in pairs(storage.item_to_entities_map) do
    if next(structs) == nil then
      storage.item_to_entities_map[item_name] = nil
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  mod.do_tasks_at_tick(event)
  mod.process_new()
  mod.process_proxies()
  mod.clean_item_to_entities_map()
end)

script.on_nth_tick(60, function()
  log(serpent.line(storage.item_to_entities_map))
  Turret.tick_turrets()
end)

local deathrattles = {
  ["ghost"] = function(deathrattle)
    local ghost = storage.all_ghosts[deathrattle.unit_number]
    storage.all_ghosts[deathrattle.unit_number] = nil

    for item_name, _ in pairs(ghost.item_name_map) do
      storage.item_to_entities_map[item_name][ghost.unit_number] = nil
    end
  end,
  ["proxy"] = function(deathrattle)
    local proxy = storage.all_proxies[deathrattle.unit_number]
    storage.all_proxies[deathrattle.unit_number] = nil

    for item_name, _ in pairs(proxy.item_name_map) do
      storage.item_to_entities_map[item_name][proxy.unit_number] = nil
    end
  end,
  ["turret"] = function(deathrattle)
    local turret = storage.turrets[deathrattle.unit_number]
    storage.all_ghosts[deathrattle.unit_number] = nil

    turret.character.destroy()
  end
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local handler = deathrattles[deathrattle.name]
    if handler then handler(deathrattle) end
  end
end)

function mod.add_task_at_tick(tick, task)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then
    tasks_at_tick[#tasks_at_tick + 1] = task
  else
    storage.tasks_at_tick[tick] = {task}
  end
end

function mod.do_tasks_at_tick(event)
  local tick = event.tick
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then storage.tasks_at_tick[tick] = nil
    for _, task in ipairs(tasks_at_tick) do
      if task.name == "revive" then
        local ghost = storage.all_ghosts[task.unit_number]
        if ghost and ghost.entity.valid then
          local spilled_items = ghost.entity.revive{raise_revive = true}
          assert(table_size(spilled_items) == 0, serpent.line(spilled_items)) -- todo: deal with later
        else
          error("refund items")
        end
      end
    end
  end
end
