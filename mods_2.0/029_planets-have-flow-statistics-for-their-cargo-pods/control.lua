local Handler = {}

script.on_init(function()
  -- cargo pods share the same unit number when they transition between surfaces
  storage.cargo_pods = {}
  storage.new_cargo_pods = {}
end)

script.on_event(defines.events.on_tick, function(event)
  for _, cargo_pod in ipairs(storage.new_cargo_pods or {}) do
    Handler.on_cargo_pod_created(cargo_pod)
  end
  storage.new_cargo_pods = {}

  -- for _, new_cargo_pod in ipairs(storage.new_cargo_pods) do
  --   storage.cargo_pods[new_cargo_pod.unit_number] = {
  --     entity = new_cargo_pod,
  --     inventory = new_cargo_pod.get_inventory(defines.inventory.cargo_unit),
  --   }
  -- end
  -- storage.new_cargo_pods = {}
  -- if storage.inventory then
  --   game.print(serpent.line(storage.inventory.get_contents()))
  --   storage.inventory = nil
  -- end
end)

local function get_flow_surface(planet_name)
  -- todo: assert space location name is of type planet
  local flow_surface_name = planet_name .. "-cargo-flow"

  local flow_surface = game.surfaces[flow_surface_name]
  if flow_surface == nil then
    flow_surface = game.create_surface(flow_surface_name)
    flow_surface.localised_name = {"", string.format("[entity=cargo-pod] [planet=%s] ", planet_name), {"space-location-name." .. planet_name}}
  end

  return flow_surface
end

function Handler.on_cargo_pod_created(entity)
  local platform = entity.surface.platform
  if platform then
    local inventory = entity.get_inventory(defines.inventory.cargo_unit)
    game.print(platform.space_location.name)
    local flow_surface = get_flow_surface(platform.space_location.name)
    local statistics = entity.force.get_item_production_statistics(flow_surface)

    for _, item in ipairs(inventory.get_contents()) do
      statistics.on_flow({name = item.name, quality = item.quality}, -item.count)
    end
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

  table.insert(storage.new_cargo_pods, event.target_entity)
end)
