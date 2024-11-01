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

function Handler.on_init(event)
  storage.structs = {}
  storage.deathrattles = {}

  -- proxies that get created with insertion plans run in the same tick,
  -- proxies created through a removal request tend to run in the next.
  storage.new_proxies = {}
end

function Handler.on_configuration_changed(event)
  storage.new_proxies = storage.new_proxies or {}
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
          local target_stack = proxy.proxy_target.get_inventory(inventory_index)[inventory_position.stack+1]
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

-- todo: if an entity gets cloned it'll already be paused,
-- as well as the new proxy trying to pause it running into an assert.
-- we'll fix it when we get a report for it, space exploration isn't ported anyways.

function Handler.remove_waiting_for_modules(entity)
  assert(entity.active == false, string.format("%s at [%d,%d,%s] unexpectedly already active.", entity.name, entity.position.x, entity.position.y, entity.surface.name))
  assert(entity.custom_status.label[1] == "entity-status.waiting-for-modules", string.format("entity.custom_status.label[1] for %s is %s but expected \"entity-status.waiting-for-modules\", please report.", entity.name, serpent.line(entity.custom_status)))
  entity.active = true
  entity.custom_status = nil
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      if struct.proxy_target.valid then
        Handler.remove_waiting_for_modules(struct.proxy_target)
      end
    end
  end
end)

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if not proxy_requests_item_we_want_to_wait_for(struct.proxy) then
      Handler.remove_waiting_for_modules(struct.proxy_target)
      storage.structs[struct_id] = nil
    end
  end
end)

function Handler.on_tick(event)
  for _, proxy in ipairs(storage.new_proxies) do
    if proxy.valid then -- proxy died in the same tick, possibly tried to request an item that doesn't fit in that slot?
      -- game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.insert_plan))
      -- game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.removal_plan))

      if not proxy_requests_item_we_want_to_wait_for(proxy) then goto continue end
      local entity = proxy.proxy_target
      assert(entity)

      assert(entity.custom_status == nil, string.format("entity.custom_status for %s is %s but expected nil, please report.", entity.name, serpent.line(entity.custom_status)))
      entity.custom_status = {
        diode = defines.entity_status_diode.yellow,
        label = {"entity-status.waiting-for-modules"},
      }

      assert(entity.active == true, string.format("entity.status for %s is true but expected false, please report.", entity.name, serpent.line(entity.custom_status)))
      entity.active = false

      local deathrattle_id = script.register_on_object_destroyed(proxy)
      storage.structs[deathrattle_id] = {
        proxy = proxy,
        proxy_target = entity,
      }

      storage.deathrattles[deathrattle_id] = {
        struct_id = deathrattle_id,
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
