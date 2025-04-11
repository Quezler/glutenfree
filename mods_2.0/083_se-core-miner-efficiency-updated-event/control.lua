local on_efficiency_updated_event_name = script.generate_event_name()

remote.add_interface("se-core-miner-efficiency-updated-event", {
  on_efficiency_updated = function() return on_efficiency_updated_event_name end,
})

local CoreMiner = require("__space-exploration-scripts__.core-miner")
local Zone = require("__space-exploration-scripts__.zone")

function on_core_miners_equalized(surface_index, prefetched_zone)
  local zone = prefetched_zone or remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface_index})

  local new_amount, efficiency = CoreMiner.get_resource_data(zone)
  zone.core_mining = {}
  local new_amount_for_one = CoreMiner.get_resource_data(zone)

  local event_data = {
    surface_index = surface_index,
    zone_index = zone.index,

    new_amount_for_one = new_amount_for_one,
    new_amount = new_amount,
    efficiency = efficiency,
  }
  -- log(serpent.block(event_data))
  script.raise_event(on_efficiency_updated_event_name, event_data)
end

function on_created_entity(event)
  local entity = event.created_entity or event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end

  -- game.print("core miner created.")
  on_core_miners_equalized(entity.surface.index)
end

function on_entity_removed(event)
  local entity = event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end

  -- game.print("core miner removed.")
  on_core_miners_equalized(entity.surface.index)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "se-core-miner-drill"},
  })
end

for _, event in ipairs({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}) do
  script.on_event(event, on_entity_removed, {
    {filter = "name", name = "se-core-miner-drill"},
  })
end

local function on_configuration_changed(event)
  for _, surface in pairs(game.surfaces) do
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
    if zone and Zone.is_solid(zone) then
      on_core_miners_equalized(surface.index, zone)
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
