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
end

script.on_init(Handler.on_init)

local function proxy_requests_item_we_want_to_wait_for(proxy)
  -- game.print(serpent.line( proxy.insert_plan ))
  -- game.print(serpent.line( proxy.removal_plan ))

  for _, blueprint_insert_plan in ipairs(proxy.insert_plan) do
    if should_wait_for_module[blueprint_insert_plan.id.name] then
      return true
    end
  end
end

-- todo: if an entity gets cloned it'll already be paused,
-- as well as the new proxy trying to pause it running into an assert.
-- we'll fix it when we get a report for it, space exploration isn't ported anyways.

function Handler.remove_waiting_for_modules(entity)
  assert(entity.active == false)
  assert(entity.custom_status.label[1] == "entity-status.waiting-for-modules")
  entity.active = true
  entity.custom_status = nil
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local proxy_target = deathrattle.proxy_target
    if proxy_target.valid then
      Handler.remove_waiting_for_modules(proxy_target)
    end
    storage.structs[deathrattle.struct_id] = nil
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

local module_inventory_for_type = {
  ["furnace"           ] = defines.inventory.furnace_modules,
  ["assembling-machine"] = defines.inventory.assembling_machine_modules,
  ["lab"               ] = defines.inventory.lab_modules,
  ["mining-drill"      ] = defines.inventory.mining_drill_modules,
  ["rocket-silo"       ] = defines.inventory.rocket_silo_modules,
  ["beacon"            ] = defines.inventory.beacon_modules,
}

local new_proxies = {}
local new_proxies_tick = nil

function Handler.on_tick(event)
  assert(new_proxies_tick == event.tick, string.format("this should have run for tick %d, not tick %d.", new_proxies_tick, event.tick))

  for _, proxy in ipairs(new_proxies) do
    if proxy.valid then -- proxy died in the same tick, possibly tried to request an item that doesn't fit in that slot?
      game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.insert_plan))
      game.print(string.format("%d %d ", event.tick, _) .. serpent.block(proxy.removal_plan))

      if not proxy_requests_item_we_want_to_wait_for(proxy) then return end
      local entity = proxy.proxy_target
      assert(entity)

      assert(entity.custom_status == nil, "some other mod has touched entity.custom_status already, do get in touch.")
      entity.custom_status = {
        diode = defines.entity_status_diode.yellow,
        label = {"entity-status.waiting-for-modules"},
      }

      assert(entity.active == true, "some other mod has touched entity.active already, do get in touch.")
      entity.active = false

      local deathrattle_id = script.register_on_object_destroyed(proxy)
      storage.structs[deathrattle_id] = {
        proxy = proxy,
        proxy_target = entity,
      }

      storage.deathrattles[deathrattle_id] = {
        struct_id = deathrattle_id,
        proxy_target = entity,
      }
    end
  end

  new_proxies = {}
  new_proxies_tick = nil
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

  new_proxies[#new_proxies+1] = proxy
  new_proxies_tick = event.tick
  script.on_event(defines.events.on_tick, Handler.on_tick)
end)
