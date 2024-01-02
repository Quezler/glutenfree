local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  assert(entity.type == "container")

  -- todo: determine the `keep` amount by silos on a surface / in a network, and possibly count launched rockets
  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    container = entity,
  }
end

script.on_init(function(event)
  global.structs = {}
  
  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered({ name = "se-rocket-launch-pad" })) do
      on_created_entity({entity = entity})
    end
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-rocket-launch-pad'},
  })
end

local unpacked_name = 'se-cargo-rocket-section'
local packed_name = 'se-cargo-rocket-section-packed'
local keep = 100

local function tick_logistic_network(logistic_network, surface_name)
  -- local unpacked_count = logistic_network.get_item_count(unpacked_name)
  local unpacked_count = logistic_network.get_supply_counts(unpacked_name).storage
  -- log(string.format('%s %d', surface_name, unpacked_count))

  if unpacked_count >= keep + 5 then
    local packed_goal = math.floor((unpacked_count - keep) / 5)
    -- log('packed_goal ' .. packed_goal)

    -- its possible for a zone to show up in the log 2 nth_ticks back to back with packing,
    -- since there might have not been enough storage for all of the to-be-packed items up front.
    -- (sure, i could re-write this since each 5 packed frees up 4 slots, but i'm about to upload)
    local inserted = logistic_network.insert({name = packed_name, count = packed_goal}, 'storage')
    if inserted > 0 then
      logistic_network.remove_item({name = unpacked_name, count = inserted * 5}, 'storage')
      log(string.format('%03d unpacked cargo rocket sections, so re-packed %02d on %s', unpacked_count, inserted, surface_name))
    else
      -- storage full
      -- log('storage full')
    end
  elseif keep > unpacked_count then
    local to_unpack = math.ceil((keep - unpacked_count) / 5)
    -- to_unpack = math.min(to_unpack, logistic_network.get_item_count(packed_name))
    to_unpack = math.min(to_unpack, logistic_network.get_supply_counts(packed_name).storage)
    -- log('to_unpack ' .. to_unpack)

    local unpacked = 0

    for i = 1, to_unpack do
      local inserted = logistic_network.insert({name = unpacked_name, count = 5}, 'storage')
      if inserted == 0 then
        -- storage full
        -- log('storage full')
      elseif inserted ~= 5 then
        -- storage almost full
        -- log('storage almost full')
        logistic_network.remove_item({name = unpacked_name, count = inserted}, 'storage')
      else
        logistic_network.remove_item({name = packed_name, count = 1}, 'storage')
        unpacked = unpacked + 1
      end
    end

    if unpacked > 0 then
      log(string.format('%03d unpacked cargo rocket sections, so un-packed %02d on %s', unpacked_count, unpacked, surface_name))
    end
  else
    -- unpacked_count in range 100 - 104
  end
end

script.on_nth_tick(60 * 10, function(event)
  for _, force in pairs(game.forces) do
    for surface_name, networks in pairs(force.logistic_networks) do
      for _, logistic_network in ipairs(networks) do
        tick_logistic_network(logistic_network, surface_name)
      end
    end
  end
end)
