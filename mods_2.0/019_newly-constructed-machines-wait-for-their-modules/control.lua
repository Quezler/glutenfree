local Handler = {}

local should_wait_for_module = {}
for _, item in pairs(prototypes.item) do
  if item.type == "module" then
    local effects = item.module_effects
    if effects then
      -- consumption, speed & pollution are ignored, its not exactly bad if a machine goes a while without any of those right? (low power perhaps)
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
-- {
--   ["productivity-module"] = true,
--   ["productivity-module-2"] = true,
--   ["productivity-module-3"] = true,
--   ["quality-module"] = true,
--   ["quality-module-2"] = true,
--   ["quality-module-3"] = true,
-- }

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  game.print(entity.name)

  local proxy = entity.surface.find_entity("item-request-proxy", entity.position)
  if proxy == nil then return end
  assert(proxy.proxy_target == entity)

  game.print(serpent.line( proxy.insert_plan ))
  -- game.print(serpent.line( proxy.removal_plan ))
end

-- local entity_types_with_module_slots = {"mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo"}
-- local on_created_entity_filter = {}
-- for _, entity_types_with_module_slot in ipairs(entity_types_with_module_slots) do
--   table.insert(on_created_entity_filter, )
-- end

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
    -- {filter = "name", name = "item-request-proxy"},
  })
end
