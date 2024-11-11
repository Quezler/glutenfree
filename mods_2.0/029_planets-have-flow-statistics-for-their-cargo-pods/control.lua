script.on_init(function()
  -- cargo pods share the same unit number when they transition between surfaces
  storage.cargo_pods = {}
end)

local function on_cargo_pod_created(event)
  game.print(event.entity.unit_number .. event.entity.surface.name .. event.entity.procession_tick)

  local inventory = event.entity.get_inventory(defines.inventory.cargo_unit)
  game.print(serpent.line(inventory.get_contents()))

  if inventory.is_empty() == false then -- in their first tick their inventory is empty, unless they transition surface
    game.print("cargo pod transitioned to destination surface")
  end
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  assert(event.target_entity.name == "cargo-pod")
  assert(event.target_entity.type == "cargo-pod")

  on_cargo_pod_created({entity = event.target_entity})
end)
