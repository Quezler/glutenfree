local Handler = {}

local get_flow_surface_name = {}
for _, space_location in pairs(prototypes.space_location) do
  if space_location.type == "planet" then
    get_flow_surface_name[space_location.name] = string.format("cargo-flow-%s-%s", space_location.order, space_location)
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

-- script.on_init(function()

-- end)

-- script.on_configuration_changed(function()

-- end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]
  assert(entity.name == "cargo-pod")
  assert(entity.type == "cargo-pod")

  game.print(string.format("new cargo pod: %d @ %s", entity.unit_number, entity.surface.name))

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
