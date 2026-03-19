---@class storage
  ---@field forcedata table<number, ForceData>
  ---@field forcedata_with_proxies table<number, ForceData>

---@class ForceData
  ---@field index number
  ---@field force LuaForce
  ---@field proxies table<number, ProxyStruct>
  ---@field proxies_pointer number?
  ---@field wants table<string, table<number, ProxyStruct>>
  ---@field logistic_networks LuaLogisticNetwork[]

---@class ProxyStruct
  ---@field index number
  ---@field entity LuaEntity
  ---@field forcedata ForceData
  ---@field wants table<string, true>

local key_to_item_id_and_quality_id_pair = {} -- filled just under the mod.id_to_key() function

local mod = {}

script.on_init(function()
  mod.on_configuration_changed()
end)

script.on_configuration_changed(function()
  mod.on_configuration_changed()
end)

function mod.on_configuration_changed()
  storage.forcedata = {}
  storage.forcedata_with_proxies = {}

  for _, force in pairs(game.forces) do
    mod.on_force_created({force = force})
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = "item-request-proxy"}) do
      mod.on_proxy_created(entity)
    end
  end
end

function mod.on_force_created(event)
  storage.forcedata[event.force.index] = {
    index = event.force.index,
    force = event.force,
    proxies = {},
    proxies_pointer = nil,
    wants = {},
    logistic_networks = {},
  }
end

function mod.on_force_deleted(event)
  local old_forcedata = storage.forcedata[event.source_index]
  local new_forcedata = storage.forcedata[event.destination.index]

  for _, proxy in pairs(old_forcedata.proxies) do
    mod.on_proxy_created(proxy.entity)
  end

  storage.forcedata[old_forcedata.index] = nil
end

script.on_event(defines.events.on_force_created, mod.on_force_created)
script.on_event(defines.events.on_forces_merged, mod.on_force_deleted)

function mod.on_proxy_created(entity)
  local forcedata = storage.forcedata[entity.force.index]

  forcedata.proxies[entity.unit_number] = {
    index = entity.unit_number,
    entity = entity,
    forcedata = forcedata,
    wants = {},
  }

  -- note: cannot refresh here (since the insert plan is nil during the created hook)

  storage.forcedata_with_proxies[forcedata.index] = forcedata
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "item-request-proxy-created" then return end

  local entity = event.target_entity --[[@as LuaEntity]]
  assert(entity.name == "item-request-proxy")

  mod.on_proxy_created(entity)
end)

---@param forcedata ForceData
function mod.tick_forcedata(forcedata)
  local proxy
  forcedata.proxies_pointer, proxy = next(forcedata.proxies, forcedata.proxies_pointer)
  if proxy then
    if proxy.entity.valid then
      mod.refresh_wants(proxy)
    else
      mod.remove_all_wants(proxy)
      if forcedata.proxies_pointer == proxy.index then -- invalid key to 'next'
        forcedata.proxies_pointer = next(forcedata.proxies, forcedata.proxies_pointer)
      end
      forcedata.proxies[proxy.index] = nil
      if not next(forcedata.proxies) then
        storage.forcedata_with_proxies[forcedata.index] = nil
      end
    end
  end

  local logistic_network_index, logistic_network = next(forcedata.logistic_networks) --[[@as number|LuaLogisticNetwork]]
  if not logistic_network then
    for _, logistic_networks in pairs(forcedata.force.logistic_networks) do
      for _, a_logistic_network in ipairs(logistic_networks) do
        if a_logistic_network.robot_limit == 4294967295 then -- cheaper than logistic_network.cells[1].owner.type == "roboport"
          table.insert(forcedata.logistic_networks, a_logistic_network)
        end
      end
    end

    -- entities just so happens to use the same get_item_count() & remove_item() calls as logistic networks, so lets include platforms too.
    for _, platform in pairs(forcedata.force.platforms) do
      local hub = platform.hub
      if hub then
        table.insert(forcedata.logistic_networks, hub)
      end
    end
  else
    forcedata.logistic_networks[logistic_network_index] = nil
    if logistic_network.valid then
      for item_key, proxies in pairs(forcedata.wants) do
        local item_id_and_quality_id_pair = key_to_item_id_and_quality_id_pair[item_key]
        local item_count = logistic_network.get_item_count(item_id_and_quality_id_pair)
        if item_count > 0 then
          local item = {
            name = item_id_and_quality_id_pair.name,
            quality = item_id_and_quality_id_pair.quality,
            count = item_count,
          }
          for _, a_proxy in pairs(proxies) do
            mod.offer_proxy_item(a_proxy, item)
            if item.count == 0 then goto remove end
          end
          ::remove::
          if item_count > item.count then
            local consumed = item_count - item.count
            local removed = logistic_network.remove_item({name = item.name, quality = item.quality, count = consumed})
            assert(removed == consumed)
          end
        end
      end
    end
  end
end

function mod.on_tick()
  for _, forcedata in pairs(storage.forcedata_with_proxies) do
    mod.tick_forcedata(forcedata)
  end
end

script.on_event(defines.events.on_tick, mod.on_tick)

---@param id BlueprintItemIDAndQualityIDPair|ItemWithQualityCount
---@return string
function mod.id_to_key(id)
  return id.name .. "," .. (id.quality or "normal")
end

-- populate the reverse lookup table
for _, item_prototype in pairs(prototypes.item) do
  for _, quality_prototype in pairs(prototypes.quality) do
    local item_id_and_quality_id_pair = {name = item_prototype.name, quality = quality_prototype.name}
    key_to_item_id_and_quality_id_pair[mod.id_to_key(item_id_and_quality_id_pair)] = item_id_and_quality_id_pair
  end
end

---@param proxy ProxyStruct
function mod.add_wants(proxy, item_key)
  -- log("proxy + " .. item_key)
  proxy.wants[item_key] = true

  proxy.forcedata.wants[item_key] = proxy.forcedata.wants[item_key] or {}
  proxy.forcedata.wants[item_key][proxy.index] = proxy
end

---@param proxy ProxyStruct
function mod.remove_wants(proxy, item_key)
  -- log("proxy - " .. item_key)
  proxy.wants[item_key] = nil

  proxy.forcedata.wants[item_key][proxy.index] = nil
  if not next(proxy.forcedata.wants[item_key]) then
    proxy.forcedata.wants[item_key] = nil
  end
end

---@param proxy ProxyStruct
function mod.remove_all_wants(proxy)
  local wants = proxy.wants
  proxy.wants = {}

  for item_key, _ in pairs(wants) do
    mod.remove_wants(proxy, item_key)
  end
end

---@param proxy ProxyStruct
function mod.refresh_wants(proxy)
  local wants = proxy.wants
  local relevant = {}

  for _, blueprint_insert_plan in ipairs(proxy.entity.insert_plan) do
    local item_key = mod.id_to_key(blueprint_insert_plan.id)

    relevant[item_key] = true
    if wants[item_key] == nil then
      mod.add_wants(proxy, item_key)
    end
  end

  for item_key, _ in pairs(wants) do
    if not relevant[item_key] then
      mod.remove_wants(proxy, item_key)
    end
  end
end

---@return InventoryPosition?
function mod.get_removal_order_for_inventory_stack(removal_plan, inventory, stack)
  for _, blueprint_insert_plan in ipairs(removal_plan) do
    local inventory_positions = blueprint_insert_plan.items.in_inventory or {}
    for _, inventory_position in ipairs(inventory_positions) do
      if inventory_position.inventory == inventory and inventory_position.stack == stack then
        return inventory_position
      end
    end
  end
end

---@param insert_plan BlueprintInsertPlan
function mod.trim_blueprint_insert_plan(insert_plan)
  -- the engine will complain if any blueprint_insert_plan requests 0, instead of cleaning it up for us
  for i = #insert_plan, 1, -1 do
    local blueprint_insert_plan = insert_plan[i]
    local keep = false

    local item_inventory_positions = blueprint_insert_plan.items.in_inventory or {}
    for _, item_inventory_position in ipairs(item_inventory_positions) do
      if item_inventory_position.count > 0 then
        keep = true
      end
    end

    if keep == false and blueprint_insert_plan.items.grid_count == nil then
      table.remove(insert_plan, i)
    end
  end
end

---@param proxy ProxyStruct
---@param item ItemWithQualityCount
function mod.offer_proxy_item(proxy, item)
  if not proxy.entity.valid then return end

  local target = proxy.entity.proxy_target
  if not target then return end

  local insert_plan = proxy.entity.insert_plan
  local insert_plan_dirty = false

  for _, blueprint_insert_plan in ipairs(insert_plan) do
    if blueprint_insert_plan.id.name == item.name and (blueprint_insert_plan.id.quality or "normal") == item.quality then
      local inventory_positions = blueprint_insert_plan.items.in_inventory or {}
      for _, inventory_position in ipairs(inventory_positions) do
        inventory_position.count = inventory_position.count or 1
        if item.count > 0 then

          local inventory = target.get_inventory(inventory_position.inventory) --[[@as LuaInventory]]
          local stack = inventory[inventory_position.stack + 1]

          local max_to_insert = math.min(item.count, inventory_position.count)

          ::retry::
          if stack.valid_for_read then
            if stack.name == item.name and stack.quality.name == item.quality then
              local old_count = stack.count
              stack.count = stack.count + max_to_insert
              local new_count = stack.count

              local consumed = new_count - old_count
              if (consumed == 0) then -- slot/stack size limit reached?
                inventory_position.count = inventory_position.count - max_to_insert -- pretend we gave it all
                insert_plan_dirty = true
              else
                item.count = item.count - consumed
                inventory_position.count = inventory_position.count - consumed
                insert_plan_dirty = true
              end
            else
              local removal_plan = proxy.entity.removal_plan
              local removal_order = mod.get_removal_order_for_inventory_stack(removal_plan, inventory_position.inventory, inventory_position.stack)
              if removal_order then
                target.surface.spill_item_stack{
                  position = target.position,
                  stack = stack,
                  force = target.force,
                  allow_belts = false,
                }
                stack.clear()

                removal_order.count = 0
                mod.trim_blueprint_insert_plan(removal_plan)
                proxy.entity.removal_plan = removal_plan
              end
              goto retry
            end
          else
            local success = stack.set_stack({name = item.name, quality = item.quality, count = max_to_insert})
            if assert(success) then
              item.count = item.count - max_to_insert
              inventory_position.count = inventory_position.count - max_to_insert
              insert_plan_dirty = true
            end
          end

        end
      end
    end
  end

  if insert_plan_dirty then
    mod.trim_blueprint_insert_plan(insert_plan)
    proxy.entity.insert_plan = insert_plan
  end
end

