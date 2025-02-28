require("shared")

local mod = {}

script.on_init(function()
  storage.deathrattles = {}

  storage.surfacedata = {}
  mod.refresh_surfacedata()

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = "cargo-bay"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function()
  mod.refresh_surfacedata()
end)

function mod.refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if surfacedata.surface.valid == false then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      surface = surface,
      cargo_bays = {}, -- unit_number -> {entity = entity, proxy = proxy}
    }
  end
end

local platform_cargo_bay_proxy_name = mod_prefix .. "platform-cargo-bay-proxy"
local planet_cargo_bay_proxy_name = mod_prefix .. "planet-cargo-bay-proxy"

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  if entity.name ~= "cargo-bay" then return entity.destroy() end

  local proxy_container = entity.surface.create_entity{
    name = entity.surface.platform and platform_cargo_bay_proxy_name or planet_cargo_bay_proxy_name,
    force = entity.force,
    position = entity.position,
  }
  proxy_container.destructible = false

  storage.surfacedata[entity.surface.index].cargo_bays[entity.unit_number] = {entity = entity, proxy = proxy_container}
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    name = "cargo-bay",
    surface_index = entity.surface_index,
    unit_number = entity.unit_number
  }
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
    {filter = "name", name = "cargo-bay"},
    {filter = "name", name = platform_cargo_bay_proxy_name},
    {filter = "name", name = planet_cargo_bay_proxy_name},
  })
end

local deathrattles = {
  ["cargo-bay"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      local cargo_bay = surfacedata.cargo_bays[deathrattle.unit_number]
      if cargo_bay then
        cargo_bay.proxy.destroy()
      end
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)
