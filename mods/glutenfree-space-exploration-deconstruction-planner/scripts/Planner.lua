local Planner = {}

function Planner.init()
  global.foundations_to_knock_down_for = {}

  global.deconstruct_next_tick = {}
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

  -- game.print(serpent.line( event.area ))
  game.print(serpent.line( #foundations ))

  for _, foundation in ipairs(foundations) do
    local ontop = event.surface.find_entities({
      {foundation.position.x + 0, foundation.position.y + 0},
      {foundation.position.x + 1, foundation.position.y + 1},
    })
    -- game.print(serpent.block( foundation.position ))
    -- game.print(serpent.block( foundation.selection_box ))
    -- game.print(#ontop)

    for _, entity in ipairs(ontop) do
      -- game.print(entity.name)
      global.foundations_to_knock_down_for[entity.unit_number] = global.foundations_to_knock_down_for[entity.unit_number] or {}
      table.insert(global.foundations_to_knock_down_for[entity.unit_number], foundation)
    end
  end
end

function Planner.on_robot_mined_entity(event)
  -- game.print(serpent.block( global.foundations_to_knock_down_for[event.entity.unit_number] ))

  local foundations = global.foundations_to_knock_down_for[event.entity.unit_number]
  if foundations then global.foundations_to_knock_down_for[event.entity.unit_number] = nil

    for _, foundation in ipairs(foundations) do
      if #global.deconstruct_next_tick == 0 then
        script.on_event(defines.events.on_tick, Planner.on_tick)
      end

      table.insert(global.deconstruct_next_tick, {
        tile = foundation,
        force = event.entity.force,
      })
    end
  end
end

function Planner.on_tick(event)
  for _, task in ipairs(global.deconstruct_next_tick) do
    task.tile.order_deconstruction(task.force)
  end

  global.deconstruct_next_tick = {}
  script.on_event(defines.events.on_tick, nil)
end

function Planner.on_cancelled_deconstruction(event)
  global.foundations_to_knock_down_for[event.entity.unit_number] = nil
end

return Planner
