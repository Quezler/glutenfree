local Handler = {}

local get_flow_surface_name = {}
for _, space_location in pairs(prototypes.space_location) do
  if space_location.type == "planet" then
    get_flow_surface_name[space_location.name] = string.format("cargo-flow-%s-%s", space_location.order, space_location)
  end
end

script.on_init(function()
  -- cargo pods share the same unit number when they transition between surfaces
  storage.cargo_pods = {}
  storage.new_cargo_pods = {}

  storage.deathrattles = {}
end)

script.on_configuration_changed(function()

end)

local function on_tick(event)
  for _, cargo_pod in ipairs(storage.new_cargo_pods) do
    Handler.on_cargo_pod_created(cargo_pod)
  end

  storage.new_cargo_pods = {}
  script.on_event(defines.events.on_tick, nil)
end

script.on_load(function()
  if next(storage.new_cargo_pods) then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

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

function Handler.on_cargo_pod_created(entity, abort_if_duplicate)
  storage.cargo_pods = storage.cargo_pods or {} -- todo: remove
  local struct = storage.cargo_pods[entity.unit_number]
  if struct and abort_if_duplicate then return end
  if struct then -- known cargo pod, just tansitioned to the other surface

    local flow_surface = get_flow_surface(struct.planet_name)
    local statistics = entity.force.get_item_production_statistics(flow_surface)

    if struct.from_planet then
      game.print("cargo pod from planet transition to platform")
      for _, item in ipairs(struct.items) do
        statistics.on_flow({name = item.name, quality = item.quality}, -item.count)
      end
    else
      game.print("cargo pod from platform transition to planet")
      for _, item in ipairs(struct.items) do
        statistics.on_flow({name = item.name, quality = item.quality}, item.count)
      end
    end

    storage.cargo_pods[entity.unit_number] = nil
    return
  end

  local platform = entity.surface.platform
  if platform then
    local inventory = entity.get_inventory(defines.inventory.cargo_unit)
    game.print("cargo pod launched from platform")

    storage.cargo_pods[entity.unit_number] = {
      entity = entity,
      planet_name = entity.surface.platform.space_location.name,
      from_planet = false,
      items = inventory.get_contents(),
    }
  else
    -- cargo pods likely created underground in a silo
  end
  -- game.print(event.entity.unit_number .. event.entity.surface.name .. event.entity.procession_tick)

  -- local inventory = event.entity.get_inventory(defines.inventory.cargo_unit)
  -- game.print(serpent.line(inventory.get_contents()))

  -- if inventory.is_empty() == false then -- in their first tick their inventory is empty, unless they transition surface
  --   game.print("cargo pod transitioned to destination surface")
  -- end

  -- storage.inventory = event.entity.get_inventory(defines.inventory.cargo_unit)
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  assert(event.target_entity.name == "cargo-pod")
  assert(event.target_entity.type == "cargo-pod")

  game.print(string.format("new cargo pod: %d @ %s", event.target_entity.unit_number, event.target_entity.surface.name))
  table.insert(storage.new_cargo_pods, event.target_entity)
  script.on_event(defines.events.on_tick, on_tick)
end)

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  local cargo_pod = event.rocket.cargo_pod --[[@as LuaEntity]]
  local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit) --[[@as LuaInventory]]
  game.print("launched rocket has: " .. serpent.line( inventory.get_contents() ))

  assert(storage.cargo_pods[cargo_pod.unit_number] == nil)
  storage.cargo_pods[cargo_pod.unit_number] = {
    entity = cargo_pod,
    planet_name = event.rocket.surface.planet.name,
    from_planet = true,
    items = inventory.get_contents(),
  }
end)
