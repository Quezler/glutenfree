local Handler = {}

local should_wait_for_module = {}
for _, item in pairs(prototypes.item) do
  if item.type == "module" then
    local effects = item.module_effects
    if effects then
      if effects.productivity and effects.productivity > 0 then
        should_wait_for_module[item.name] = true
      end
      if effects.quality and effects.quality > 0 then
        should_wait_for_module[item.name] = true
      end
    end
  end
end
-- log(serpent.block(should_wait_for_module))

local entity_status_name = {}
for name, value in pairs(defines.entity_status) do
  entity_status_name[value] = name
end

function Handler.on_init(event)
  storage.structs = {}
  storage.deathrattles = {}

  -- proxies that get created with insertion plans run in the same tick,
  -- proxies created through a removal request tend to run in the next.
  storage.new_proxies = {}

  storage.proxy_that_makes_this_entity_wait = {}
end

function Handler.on_configuration_changed(event)
  storage.new_proxies = storage.new_proxies or {}
  storage.proxy_that_makes_this_entity_wait = storage.proxy_that_makes_this_entity_wait or {}
end

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

local module_inventory_for_type = {
  ["furnace"           ] = defines.inventory.furnace_modules,            -- 4
  ["assembling-machine"] = defines.inventory.assembling_machine_modules, -- 4
  ["lab"               ] = defines.inventory.lab_modules,                -- 3
  ["mining-drill"      ] = defines.inventory.mining_drill_modules,       -- 2
  ["rocket-silo"       ] = defines.inventory.rocket_silo_modules,        -- 4
  ["beacon"            ] = defines.inventory.beacon_modules,             -- 1
}

local function proxy_requests_item_we_want_to_wait_for(proxy)
  local inventory_index = module_inventory_for_type[proxy.proxy_target.type]

  for _, blueprint_insert_plan in ipairs(proxy.insert_plan) do
    if should_wait_for_module[blueprint_insert_plan.id.name] then
      for _, inventory_position in ipairs(blueprint_insert_plan.items.in_inventory) do
        -- this item is a module, has productivity or quality, and is requested for a module slot
        if inventory_position.inventory == inventory_index then
          local slot = inventory_position.stack + 1
          local module_inventory = proxy.proxy_target.get_inventory(inventory_index)
          if slot > #module_inventory then
            return true -- requesting a module for a slot that doesn't exist yet (e.g. pending assembler 2 to 3 upgrade) gets treated as empty
          end
          local target_stack = module_inventory[slot]
          if target_stack.valid_for_read == false then
            return true -- target slot is empty
          elseif should_wait_for_module[target_stack.name] then
            -- swapping with a productivity/quality module of any tier/quality
          else
            return true -- target slot has a module we're not waiting for
          end
        end
      end
    end
  end
end

function entity_debug_information(entity)
  return serpent.block({
    type = entity.type,
    name = entity.name,

    force = entity.force.name,
    surface = entity.surface.name,
    position = entity.position,

    active = entity.active,
    status = entity_status_name[entity.status],
    custom_status = entity.custom_status,

    last_user = entity.last_user and entity.last_user.name or nil,
  }, {sortkeys = false})
end

-- todo: if an entity gets cloned it'll already be paused,
-- as well as the new proxy trying to pause it running into an assert.
-- we'll fix it when we get a report for it, space exploration isn't ported anyways.

function Handler.remove_waiting_for_modules(entity)
  assert(entity.active == false, "the entity is already active. " .. entity_debug_information(entity))
  assert(entity.custom_status.label[1] == "entity-status.waiting-for-modules", "the entity is not waiting for modules. " .. entity_debug_information(entity))
  entity.active = true
  entity.custom_status = nil
end

function Handler.on_object_destroyed(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      if struct.proxy_target.valid then
        Handler.remove_waiting_for_modules(struct.proxy_target)
      end
    end
  end
end

script.on_event(defines.events.on_object_destroyed, Handler.on_object_destroyed)

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if not proxy_requests_item_we_want_to_wait_for(struct.proxy) then
      Handler.remove_waiting_for_modules(struct.proxy_target)
      storage.structs[struct_id] = nil
    end
  end
end)

local skip_active_true_check = {
  [defines.entity_status.frozen] = true,
--[defines.entity_status.recipe_is_parameter] = true,
  [defines.entity_status.recipe_not_researched] = true,
  [defines.entity_status.disabled_by_control_behavior] = true,
}

function Handler.on_tick(event)
  for _, proxy in ipairs(storage.new_proxies) do
    if proxy.valid then -- proxy died in the same tick, possibly tried to request an item that doesn't fit in that slot?
      -- game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.insert_plan))
      -- game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.removal_plan))

      if not proxy_requests_item_we_want_to_wait_for(proxy) then goto continue end
      local entity = proxy.proxy_target
      assert(entity)
      assert(entity.unit_number)

      -- if the last module ghost of a proxy is swapped with a new module ghost a new item request proxy gets created,
      -- but this new proxy is reaching this bit of code before on_object_destroyed runs, so we manually deathrattle it.
      local proxy_that_makes_this_entity_wait = storage.proxy_that_makes_this_entity_wait[entity.unit_number]
      if proxy_that_makes_this_entity_wait then
        assert(proxy_that_makes_this_entity_wait.proxy.valid == false)
        assert(proxy_that_makes_this_entity_wait.proxy_target.valid == true)
        Handler.on_object_destroyed({registration_number = proxy_that_makes_this_entity_wait.deathrattle_id})
      end

      assert(entity.custom_status == nil, "expected entity.custom_status to be nil. " .. entity_debug_information(entity))
      entity.custom_status = {
        diode = defines.entity_status_diode.yellow,
        label = {"entity-status.waiting-for-modules"},
      }

      -- if an entity is frozen their .active reads as false
      if not skip_active_true_check[entity.status] then
        if entity.type == "assembling-machine" and entity.get_recipe() and entity.get_recipe().prototype.is_parameter then
          -- await defines.entity_status.recipe_is_parameter, possibly in 2.0.22?
          else
          assert(entity.active == true, "expected entity.active to be true. " .. entity_debug_information(entity))
        end
      end
      -- but we'll still have to set .active to false or it'll start crafting when it becomes unfrozen,
      -- fortunatently a lua'd .active doesn't get reset when the entity unfreezes, so it keeps waiting.
      entity.active = false

      local deathrattle_id = script.register_on_object_destroyed(proxy)
      storage.structs[deathrattle_id] = {
        proxy = proxy,
        proxy_target = entity,
        proxy_target_unit_number = entity.unit_number,
      }

      storage.deathrattles[deathrattle_id] = {
        struct_id = deathrattle_id,
      }

      storage.proxy_that_makes_this_entity_wait[entity.unit_number] = {
        proxy = proxy,
        proxy_target = entity,
        deathrattle_id = deathrattle_id,
      }
    end
    ::continue::
  end

  storage.new_proxies = {}
  script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "item-request-proxy-created" then return end

  local proxy = event.target_entity
  assert(proxy)
  assert(proxy.type == "item-request-proxy")
  assert(proxy.proxy_target)

  local module_inventory_index = module_inventory_for_type[proxy.proxy_target.type]
  if module_inventory_index == nil then return end -- type does not have a module inventory

  table.insert(storage.new_proxies, proxy)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end)

script.on_load(function()
  if storage.new_proxies and next(storage.new_proxies) then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

-- when an entity that was "waiting for modules" dies the custom status apparently persists in the ghost,
-- so when it is revived (no specific event, so we listen to all of them) we'll clear the custom status to be sure,
-- when this code runs the proxy will already exist and have an insert plan, but it shouldn't have reached on_tick yet.
-- nevertheless this feels incredibly fragile, but it seems to work well enough for now, lets see what the test of time says.
function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  if entity.custom_status and entity.custom_status.label[1] == "entity-status.waiting-for-modules" then
    entity.custom_status = nil
    entity.active = true
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "type", type = "mining-drill"},
    {filter = "type", type = "furnace"},
    {filter = "type", type = "assembling-machine"},
    {filter = "type", type = "lab"},
    {filter = "type", type = "beacon"},
    {filter = "type", type = "rocket-silo"},
  })
end

script.on_nth_tick(60 * 60, function(event) -- gc
  for proxy_target_unit_number, proxy_that_makes_this_entity_wait in pairs(storage.proxy_that_makes_this_entity_wait) do
    if proxy_that_makes_this_entity_wait.proxy.valid == false or proxy_that_makes_this_entity_wait.proxy_target.valid == false then
      proxy_that_makes_this_entity_wait[proxy_target_unit_number] = nil
    end
  end
end)
