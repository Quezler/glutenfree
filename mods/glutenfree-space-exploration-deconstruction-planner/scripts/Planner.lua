local Planner = {}

function Planner.init()
  global.foundations_to_knock_down_for = {}
end

function Planner.on_player_selected_area(event)
  local player = game.get_player(event.player_index)

  for _, entity in ipairs(event.entities) do
    entity.order_deconstruction(player.force, player)
  end

  for _, tile in ipairs(event.tiles) do
    tile.order_deconstruction(player.force, player)
  end

  -- which tiles are current supporting buildings?
  local foundations = event.surface.find_tiles_filtered({
    area = event.area,
    name = {'se-space-platform-scaffold', 'se-space-platform-plating', 'se-spaceship-floor'},
    to_be_deconstructed = false,
  })

  for _, foundation in ipairs(foundations) do
    local ontop = event.surface.find_entities({
      {foundation.position.x + 0, foundation.position.y + 0},
      {foundation.position.x + 1, foundation.position.y + 1},
    })

    for _, entity in ipairs(ontop) do
      local struct = global.foundations_to_knock_down_for[entity.unit_number] or {
        entity = entity,
        force = player.force,
        player = player,
        foundations = {}
      }

      table.insert(struct.foundations, foundation)
      global.foundations_to_knock_down_for[entity.unit_number] = struct

      -- could cause lingering uint64's though :o
      script.register_on_entity_destroyed(entity)
    end
  end
end

function Planner.on_entity_destroyed(event)
  local struct = global.foundations_to_knock_down_for[event.unit_number]
  if struct then global.foundations_to_knock_down_for[event.unit_number] = nil

    for _, foundation in ipairs(struct.foundations) do
      foundation.order_deconstruction(struct.force, struct.player)
    end

  end
end

function Planner.on_cancelled_deconstruction(event)
  global.foundations_to_knock_down_for[event.entity.unit_number] = nil
end

function Planner.on_player_alt_selected_area(event)
  local player = game.get_player(event.player_index)

  -- will propogate through `on_cancelled_deconstruction` above
  for _, entity in ipairs(event.entities) do
    entity.cancel_deconstruction(player.force, player)
  end

  for _, tile in ipairs(event.tiles) do
    tile.cancel_deconstruction(player.force, player)
  end
end

return Planner
