-- commands.add_command("cliff-dimension", nil, function(command)
--   local player = game.get_player(command.player_index)
--   local surface_name = player.surface.name .. '-cliff-reconstruction'

--   game.create_surface(surface_name, player.surface.map_gen_settings)

--   player.teleport(player.position, surface_name)
-- end)

local function position_equals(a, b)
  return a.x == b.x and a.y == b.y
end

local function should_clone(cliff, existing_cliffs)
  -- log('checking against:')
  -- log(cliff.position)
  for _, existing_cliff in ipairs(existing_cliffs) do
    -- log(existing_cliff.position)
    -- log(serpent.line(existing_cliff.position == cliff.position))
    if position_equals(existing_cliff.position, cliff.position) then return false end
    -- if existing_cliff.position == cliff.position then return false end
  end

  return true
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "cliff-reconstruction-selection-tool" then return end

  local player = game.get_player(event.player_index)
  if player == nil then return end

  if player.admin == false then
    player.create_local_flying_text({text = 'Cliff reconstruction is only.', create_at_cursor = true})
    return
  end

  -- game.print(serpent.line(event.area))

  local center = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2,
  }

  local surface = game.create_surface(player.surface.name .. '-cliff-reconstruction', player.surface.map_gen_settings)
  surface.request_to_generate_chunks(center, 1) -- 3x3
  surface.force_generate_chunk_requests()

  local existing_cliffs = event.surface.find_entities_filtered{area = event.area, type = 'cliff'}
  local to_clone_cliffs =       surface.find_entities_filtered{area = event.area, type = 'cliff'}

  for _, to_clone_cliff in ipairs(to_clone_cliffs) do
    if should_clone(to_clone_cliff, existing_cliffs) then
      local cloned_cliff = to_clone_cliff.clone{
        position = to_clone_cliff.position,
        surface = event.surface,
      }
      assert(cloned_cliff and cloned_cliff.valid)
    end
  end

  game.delete_surface(surface) -- todo: surface name is always the same, possible race condition
end)

script.on_event(defines.events.on_player_reverse_selected_area, function(event)
  if event.item ~= "cliff-reconstruction-selection-tool" then return end

  local player = game.get_player(event.player_index)
  if player == nil then return end

  if player.admin == false then
    player.create_local_flying_text({text = 'Cliff reconstruction is only.', create_at_cursor = true})
    return
  end

  local existing_cliffs = event.surface.find_entities_filtered{area = event.area, type = 'cliff'}

  for _, existing_cliff in ipairs(existing_cliffs) do
    existing_cliff.destroy()
  end
end)
