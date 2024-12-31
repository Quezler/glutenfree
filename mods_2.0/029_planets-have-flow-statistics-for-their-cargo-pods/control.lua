local Handler = {}

local setting_name_uninstalled = "planets-have-flow-statistics-for-their-cargo-pods--uninstalled"

-- mistakenly .name was forgotten so you'd see a lot of `[LuaSpaceLocationPrototype: nauvis (planet)]` stuff
local get_old_flow_surface_name = {}
for _, space_location in pairs(prototypes.space_location) do
  if space_location.type == "planet" then
    get_old_flow_surface_name[space_location.name] = string.format("cargo-flow-%s-%s", space_location.order, space_location)
  end
end

local get_flow_surface_name = {}
for _, space_location in pairs(prototypes.space_location) do
  if space_location.type == "planet" then
    get_flow_surface_name[space_location.name] = string.format("cargo-flow-%s-%s", space_location.order, space_location.name)
  end
end

local function get_flow_surface(planet_name)
  local flow_surface_name = get_flow_surface_name[planet_name]
  assert(flow_surface_name, planet_name .. " is not a planet")

  local flow_surface = game.surfaces[flow_surface_name]
  if flow_surface == nil then
    flow_surface = game.create_surface(flow_surface_name)
    flow_surface.localised_name = {"", string.format("[entity=cargo-pod] [planet=%s] ", planet_name), {"space-location-name." .. planet_name}}
  end

  return flow_surface
end

script.on_init(function()
  storage.uninstalled = settings.global[setting_name_uninstalled].value
end)

script.on_configuration_changed(function()
  storage.uninstalled = settings.global[setting_name_uninstalled].value

  -- for _, surface in pairs(game.surfaces) do
  --   if get_old_flow_surface_name[surface.name] then
  --     surface.name = get_flow_surface_name[surface.name]
  --   end
  -- end

  for surface_name, old_flow_surface_name in pairs(get_old_flow_surface_name) do
    local surface = game.surfaces[old_flow_surface_name]
    if surface then
      surface.name = get_flow_surface_name[surface_name]
    end
  end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]
  assert(entity.name == "cargo-pod")
  assert(entity.type == "cargo-pod")

  if storage.uninstalled then return end

  -- game.print(string.format("new cargo pod: %d @ %s", entity.unit_number, entity.surface.name))

  -- the inventory is empty when:
  -- A) the cargo pod got created underground in the silo (exists before rocket launch)
  -- B) the cargo pod got launched from a platform (trigger fires before inventory insertion)
  -- C) there is a player traveling in the cargo pod
  local inventory = event.target_entity.get_inventory(defines.inventory.cargo_unit) --[[@as LuaInventory]]
  if inventory.is_empty() then return end

  local platform = entity.surface.platform
  local flow_surface = get_flow_surface(platform and platform.space_location.name or entity.surface.planet.name)
  local statistics = entity.force.get_item_production_statistics(flow_surface)
  local multiplier = platform and 1 or -1 -- production = send up, consumption = requesting

  for _, item in ipairs(inventory.get_contents()) do
    statistics.on_flow({name = item.name, quality = item.quality}, item.count * multiplier)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-global" then
    if event.setting == setting_name_uninstalled then
      storage.uninstalled = settings.global[setting_name_uninstalled].value
      if storage.uninstalled then
        for surface_name, flow_surface_name in pairs(get_flow_surface_name) do
          if game.surfaces[flow_surface_name] then
            game.delete_surface(flow_surface_name)
          end
        end
      end
    end
  end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.controller_type == defines.controllers.character then
    if player.surface.find_entity("cargo-pod", player.position) then
      game.print("player in cargo pod!")
    end
  end
end)
