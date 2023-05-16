local function sum_chunks()
  local chunks = {}

  for _, surface in pairs(game.surfaces) do
    chunks[surface.index] = 0
    for chunk in surface.get_chunks() do
      if surface.is_chunk_generated(chunk) then
        chunks[surface.index] = chunks[surface.index] + 1
      end
    end
  end

  return chunks
end

script.on_init(function(event)
  global.chunks = sum_chunks()
  global.ticks_played_on_init = game.ticks_played
end)

-- script.on_event(defines.events.on_chunk_generated, function(event)
--   if game.ticks_played == global.ticks_played_on_init then return end
--   global.chunks[event.surface.index] = global.chunks[event.surface.index] + 1

--   -- game.print('tick ' .. event.tick .. ' cached chunks: ' .. serpent.line(global.chunks))
--   -- game.print('tick ' .. event.tick .. ' summed chunks: ' .. serpent.line(sum_chunks()))

--   print('at tick ' .. event.tick .. ' nauvis has ' .. sum_chunks()[1] .. ' chunks yet we\'ve tracked ' .. global.chunks[1])
-- end)

script.on_event(defines.events.on_chunk_generated, function(event)
  if game.ticks_played == global.ticks_played_on_init then return end
  global.chunks[event.surface.index] = global.chunks[event.surface.index] + 1

  print('at tick ' .. event.tick .. ' nauvis has ' .. sum_chunks()[1] .. ' chunks yet we\'ve tracked ' .. global.chunks[1])
end)


script.on_event(defines.events.on_chunk_deleted, function(event)
  if game.ticks_played == global.ticks_played_on_init then return end
  global.chunks[event.surface_index] = global.chunks[event.surface_index] - #event.positions
  print('#deleted: ' .. #event.positions)

  print('at tick ' .. event.tick .. ' nauvis has ' .. sum_chunks()[1] .. ' chunks yet we\'ve tracked ' .. global.chunks[1])
end)

--

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
  game.print('a computed chunks: ' .. serpent.line(sum_chunks()))

  local chunk_radius = 5;
  for chunk in surface.get_chunks() do
    if (chunk.x < -chunk_radius or chunk.x > chunk_radius or chunk.y < -chunk_radius or chunk.y > chunk_radius) then
      if surface.is_chunk_generated(chunk) then
        surface.delete_chunk(chunk)
      end
    end
  end

  game.print('b tracked chunks: ' .. serpent.line(global.chunks))
  game.print('b computed chunks: ' .. serpent.line(sum_chunks()))

end)
