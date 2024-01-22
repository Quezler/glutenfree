local CoreMiner = require('__space-exploration-scripts__.core-miner')

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function on_core_miners_equalized(surface_index)
  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface_index})

  zone.core_mining = {}
  local new_amount, efficiency, mined_resources = CoreMiner.get_resource_data(zone)
  -- game.print(serpent.line({new_amount, efficiency}))

  for _, resource_set in pairs(zone.core_seam_resources) do
    local resource = resource_set.resource
    resource.amount = new_amount

    local entities = resource.surface.find_entities_filtered{
      position = resource.position,
      name = 'flying-text',
    }

    for _, entity in ipairs(entities) do
      if ends_with(entity.text, ' effective') then
        entity.destroy()
      end
    end
  end
end

function on_created_entity(event)
  local entity = event.created_entity or event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end

  -- game.print('core miner created.')
  on_core_miners_equalized(entity.surface.index)
end

function on_entity_removed(event)
  local entity = event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end

  -- game.print('core miner removed.')
  on_core_miners_equalized(entity.surface.index)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-core-miner-drill'},
  })
end

for _, event in ipairs({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
  defines.events.on_entity_died,
  defines.events.script_raised_destroy,
}) do
  script.on_event(event, on_entity_removed, {
    {filter = 'name', name = 'se-core-miner-drill'},
  })
end

-- the entry points to equalize that we still need to handle:
-- CoreMiner.equalise_all() (on_configuration_changed)
-- CoreMiner.equalise() (generate_core_seam_positions)
