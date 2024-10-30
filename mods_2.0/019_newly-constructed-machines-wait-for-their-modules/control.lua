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

local function proxy_requests_item_we_want_to_wait_for(proxy)
  -- game.print(serpent.line( proxy.insert_plan ))
  -- game.print(serpent.line( proxy.removal_plan ))

  for _, blueprint_insert_plan in ipairs(proxy.insert_plan) do
    if should_wait_for_module[blueprint_insert_plan.id.name] then
      return true
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  -- game.print(entity.name)

  local proxy = entity.surface.find_entity("item-request-proxy", entity.position)
  if proxy == nil then return end
  assert(proxy.proxy_target == entity)

  if not proxy_requests_item_we_want_to_wait_for(proxy) then return end

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

-- local entity_types_with_module_slots = {"mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo"}

script.on_init(Handler.on_init)

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
