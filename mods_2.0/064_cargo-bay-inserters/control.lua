require("shared")

local mod = {}

script.on_init(function()
  storage.deathrattles = {}

  storage.surfacedata = {}
  mod.refresh_surfacedata()
  storage.dirty_surfaces = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = {"cargo-bay", "space-platform-hub", "cargo-landing-pad"}})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function()
  mod.refresh_surfacedata()
  mod.update_proxies_for_surfaces()
end)

script.on_load(function()
  if next(storage.dirty_surfaces) then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
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
      space_platform_hubs = {}, -- unit_number -> {entity = entity}
      cargo_landing_pads = {},  -- unit_number -> {entity = entity}
      cargo_bays = {},          -- unit_number -> {entity = entity, proxy = proxy}
    }
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)

local platform_cargo_bay_proxy_name = mod_prefix .. "platform-cargo-bay-proxy"
local planet_cargo_bay_proxy_name = mod_prefix .. "planet-cargo-bay-proxy"

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == platform_cargo_bay_proxy_name then return entity.destroy() end
  if entity.name == planet_cargo_bay_proxy_name then return entity.destroy() end

  local surfacedata = storage.surfacedata[entity.surface.index]

  if entity.type == "cargo-bay" then
    local proxy_container = entity.surface.create_entity{
      name = entity.surface.platform and platform_cargo_bay_proxy_name or planet_cargo_bay_proxy_name,
      force = entity.force,
      position = entity.position,
    }
    proxy_container.destructible = false
    proxy_container.proxy_target_inventory = entity.surface.platform and defines.inventory.hub_main or defines.inventory.cargo_landing_pad_main

    surfacedata.cargo_bays[entity.unit_number] = {entity = entity, proxy = proxy_container}
    storage.deathrattles[script.register_on_object_destroyed(entity)] = {
      name = "cargo-bay",
      surface_index = entity.surface_index,
      unit_number = entity.unit_number,
    }
  elseif entity.type == "space-platform-hub" then
    surfacedata.space_platform_hubs[entity.unit_number] = {entity = entity}
    storage.deathrattles[script.register_on_object_destroyed(entity)] = {
      name = "space-platform-hub",
      surface_index = entity.surface_index,
      unit_number = entity.unit_number,
    }
  elseif entity.type == "cargo-landing-pad" then
    surfacedata.cargo_landing_pads[entity.unit_number] = {entity = entity}
    storage.deathrattles[script.register_on_object_destroyed(entity)] = {
      name = "cargo-landing-pad",
      surface_index = entity.surface_index,
      unit_number = entity.unit_number,
    }
  end

  mod.mark_surface_dirty(entity.surface)
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
    {filter = "type", type = "cargo-bay"},
    {filter = "type", type = "space-platform-hub"},
    {filter = "type", type = "cargo-landing-pad"},
    {filter = "name", name = platform_cargo_bay_proxy_name},
    {filter = "name", name = planet_cargo_bay_proxy_name},
  })
end

local deathrattles = {
  ["cargo-bay"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      local cargo_bay = surfacedata.cargo_bays[deathrattle.unit_number]
      if cargo_bay then surfacedata.cargo_bays[deathrattle.unit_number] = nil
        cargo_bay.proxy.destroy()
      end
      mod.mark_surface_dirty(surfacedata.surface)
    end
  end,
  ["space-platform-hub"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      surfacedata.space_platform_hubs[deathrattle.unit_number] = nil
      mod.mark_surface_dirty(surfacedata.surface)
    end
  end,
  ["cargo-landing-pad"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      surfacedata.cargo_landing_pads[deathrattle.unit_number] = nil
      mod.mark_surface_dirty(surfacedata.surface)
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)

function mod.update_proxies_for_surface(surface)
  local surfacedata = storage.surfacedata[surface.index]
  local map = {}

  -- log(serpent.line(surfacedata))

  if surface.platform and surface.platform.hub and not surfacedata.space_platform_hubs[surface.platform.hub.unit_number] then
    mod.on_created_entity({entity = surface.platform.hub})
  end

  for _, space_platform_hub in pairs(surfacedata.space_platform_hubs) do
    if space_platform_hub.entity.valid then
      for _, cargo_bay in ipairs(space_platform_hub.entity.get_cargo_bays()) do
        map[cargo_bay.unit_number] = {entity = space_platform_hub.entity}
      end
    end
  end
  for _, cargo_landing_pad in pairs(surfacedata.cargo_landing_pads) do
    if cargo_landing_pad.entity.valid then
      for _, cargo_bay in ipairs(cargo_landing_pad.entity.get_cargo_bays()) do
        map[cargo_bay.unit_number] = {entity = cargo_landing_pad.entity}
      end
    end
  end

  -- game.print(serpent.line(map))

  for _, cargo_bay in pairs(surfacedata.cargo_bays) do
    if cargo_bay.entity.valid then
      cargo_bay.proxy.destructible = false -- 1.0.3 - 1.0.4
      local target = map[cargo_bay.entity.unit_number]
      if target then
        cargo_bay.proxy.proxy_target_entity = target.entity
      else
        cargo_bay.proxy.proxy_target_entity = nil
      end
    end
  end
end

function mod.update_proxies_for_surfaces()
  for _, surface in pairs(game.surfaces) do
    mod.update_proxies_for_surface(surface)
  end
end

function mod.on_tick(event)
  for surface_index, _ in pairs(storage.dirty_surfaces) do
    local surface = game.get_surface(surface_index)
    if surface then mod.update_proxies_for_surface(surface) end
  end
  storage.dirty_surfaces = {}
  script.on_event(defines.events.on_tick, nil)
end

function mod.mark_surface_dirty(surface)
  if not next(storage.dirty_surfaces) then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end

  storage.dirty_surfaces[surface.index] = true
end

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.name == "cargo-bay" then
    local proxy = event.entity.surface.find_entity(platform_cargo_bay_proxy_name, event.entity.position)
    if proxy then
      proxy.destroy()
    end
  end
end, {
  {filter = "type", type = "cargo-bay"},
})
