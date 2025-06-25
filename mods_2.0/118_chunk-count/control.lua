local function sum_chunks_for_surface(surface)
  local chunks = 0

  for chunk in surface.get_chunks() do
    if surface.is_chunk_generated(chunk) then
      chunks = chunks + 1
    end
  end

  return chunks
end

local function sum_chunks_for_surfaces()
  local chunks = {}

  for _, surface in pairs(game.surfaces) do
    chunks[surface.index] = sum_chunks_for_surface(surface)
  end

  return chunks
end

script.on_init(function()
  storage.chunks = sum_chunks_for_surfaces()
  storage.ticks_played_on_init = game.ticks_played
end)

script.on_configuration_changed(function()
  storage.chunks = sum_chunks_for_surfaces()
end)

script.on_event(defines.events.on_chunk_generated, function(event)
  if game.ticks_played == storage.ticks_played_on_init then return end
  storage.chunks[event.surface.index] = storage.chunks[event.surface.index] + 1

  -- print("at tick " .. event.tick .. " nauvis has " .. sum_chunks_for_surfaces()[1] .. " chunks yet we\"ve tracked " .. storage.chunks[1])
end)


script.on_event(defines.events.on_chunk_deleted, function(event)
  if game.ticks_played == storage.ticks_played_on_init then return end
  storage.chunks[event.surface_index] = sum_chunks_for_surface(game.get_surface(event.surface_index))

  -- print("at tick " .. event.tick .. " nauvis has " .. sum_chunks_for_surfaces()[1] .. " chunks yet we\"ve tracked " .. storage.chunks[1])
end)

script.on_event(defines.events.on_surface_created, function(event)
  storage.chunks[event.surface_index] = 0 -- assume no starting chunks exist and every single one calls on_chunk_generated
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.chunks[event.surface_index] = nil
end)

--

commands.add_command("chunk-count", "Run integrity check.", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if not player.admin then return end

  game.print("summed: " .. serpent.line(sum_chunks_for_surfaces()))
  game.print("cached: " .. serpent.line(storage.chunks))
end)

--

remote.add_interface("chunk-count", {
  get = function(data)
    if data and data.surface_index then
      return storage.chunks[data.surface_index]
    else
      return storage.chunks
    end
  end,
})
