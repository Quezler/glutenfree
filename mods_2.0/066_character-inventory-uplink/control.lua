require("shared")
local mod = {}

script.on_init(function ()
  storage.entitydata = {}
  storage.deathrattles = {}
end)

mod.on_created_entity_filters = {
  {filter = "name", name = mod_name},
  {filter = "name", name = mod_prefix .. "proxy-container"},
}

function mod.create_entitydata(entity, data)
  data.entity = entity
  data.unit_number = entity.unit_number
  storage.entitydata[entity.unit_number] = data
  return data
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "proxy-container" then
    return entity.destroy()
  end

  local entitydata = mod.create_entitydata(entity, {
    proxy = nil,
  })
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = mod_name, unit_number = entity.unit_number}

  entitydata.proxy = entity.surface.create_entity{
    name = mod_prefix .. "proxy-container",
    force = entity.force,
    position = entity.position,
  }
  entitydata.proxy.destructible = false

  if entity.last_user then
    entitydata.proxy.proxy_target_entity = entity.last_user.character
    entitydata.proxy.proxy_target_inventory = defines.inventory.character_main
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

local deathrattles = {
  [mod_name] = function (deathrattle)
    local entitydata = storage.entitydata[deathrattle.unit_number]
    if entitydata then storage.entitydata[deathrattle.unit_number] = nil
      entitydata.proxy.destroy()
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)
