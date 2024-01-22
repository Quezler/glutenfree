local CoreMiner = require('__space-exploration-scripts__.core-miner')

function on_core_miners_equalized()
  -- calculate & set the amount as though there is one miner
  -- delete flying texts at all core seams
end

function on_created_entity(event)
  local entity = event.created_entity or event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end
  game.print('core miner created.')
end

function on_entity_removed(event)
  local entity = event.entity
  if entity.name ~= CoreMiner.name_core_miner_drill then return end
  game.print('core miner removed.')
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
