require("shared")
local mod = {}

script.on_init(function ()
  storage.entitydata = {}
end)

mod.on_created_entity_filters = {
  {filter = "name", name = mod_name},
  {filter = "name", name = mod_prefix .. "proxy-container"},
}

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "proxy-container" then
    return entity.destroy()
  end

  storage.entitydata[entity.unit_number] = {
    entity = entity,
    proxy = nil,
  }

  local proxy = entity.surface.create_entity{
    name = mod_prefix .. "proxy-container",
    force = entity.force,
    position = entity.position,
  }
  proxy.destructible = false
  storage.entitydata[entity.unit_number].proxy = proxy

  if entity.last_user then
    proxy.proxy_target_entity = entity.last_user.character
    proxy.proxy_target_inventory = defines.inventory.character_main
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
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end
