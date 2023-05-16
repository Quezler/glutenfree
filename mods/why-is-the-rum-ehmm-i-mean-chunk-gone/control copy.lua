local Handler = {}

function Handler.on_init()
  global.chunks = {}

  for _, surface in pairs(game.surfaces) do
    global.chunks[surface.index] = 0
    for chunk in surface.get_chunks() do
      global.chunks[surface.index] = global.chunks[surface.index] + 1
    end
  end

  -- game.print('welcome traveler! here are your chunks:')
  -- game.print(serpent.block(global.chunks))
end

function Handler.on_chunk_generated(event)
  global.chunks[event.surface.index] = global.chunks[event.surface.index] + 1
  game.print(event.surface.index .. ' now has ' .. global.chunks[event.surface.index])
end

function Handler.on_chunk_deleted(event)
  game.print('deleted ' .. #event.positions .. ',')
  global.chunks[event.surface_index] = global.chunks[event.surface_index] - #event.positions
  game.print(event.surface_index .. ' now has ' .. global.chunks[event.surface_index])

  game.print('b tracked chunks: ' .. serpent.line(global.chunks))
  game.print('b computed chunks: ' .. serpent.line(Handler.compute_chunks()))
end

function Handler.compute_chunks()
  local chunks = {}

  for _, surface in pairs(game.surfaces) do
    chunks[surface.index] = 0
    for chunk in surface.get_chunks() do
      chunks[surface.index] = chunks[surface.index] + 1
    end
  end

  return chunks
end

--

script.on_init(Handler.on_init)

script.on_event(defines.events.on_chunk_generated, Handler.on_chunk_generated)
script.on_event(defines.events.on_chunk_deleted, Handler.on_chunk_deleted)

--

commands.add_command("chunks", "Gib chunk count.", function(event)
  local player = game.get_player(event.player_index)
  -- game.print(player.surface.name .. "'s chunk count = " .. global.chunks[player.surface.index])

  game.print('c tracked chunks: ' .. serpent.line(global.chunks))
  game.print('c computed chunks: ' .. serpent.line(Handler.compute_chunks()))
end)

commands.add_command("chart", "Do some charting.", function(event)
  local player = game.get_player(event.player_index)
  local radius=1500
  player.force.chart(game.player.surface, {{x = -radius, y = -radius}, {x = radius, y = radius}})
end)

commands.add_command("delete", "Do some purging.", function(event)
  local player = game.get_player(event.player_index)
  local surface = player.surface

  player.force.cancel_charting(surface);

  game.print('a tracked chunks: ' .. serpent.line(global.chunks))
  game.print('a computed chunks: ' .. serpent.line(Handler.compute_chunks()))

  local chunk_radius = 5;
  for chunk in surface.get_chunks() do
    if (chunk.x < -chunk_radius or chunk.x > chunk_radius or chunk.y < -chunk_radius or chunk.y > chunk_radius) then
      surface.delete_chunk(chunk)
    end
  end

  -- game.print('b tracked chunks: ' .. serpent.line(global.chunks))
  -- game.print('b computed chunks: ' .. serpent.line(Handler.compute_chunks()))
end)

-- /c local radius=1500 game.player.force.chart(game.player.surface, {{x = -radius, y = -radius}, {x = radius, y = radius}})

-- /c local surface = game.player.surface;
-- game.player.force.cancel_charting(surface); 
-- local chunk_radius = 5;
-- for chunk in surface.get_chunks() do
--   if (chunk.x < -chunk_radius or chunk.x > chunk_radius or chunk.y < -chunk_radius or chunk.y > chunk_radius) then
--     surface.delete_chunk(chunk)
--   end
-- end
