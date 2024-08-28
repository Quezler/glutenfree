local function on_chunk_generated(event)
  if event.surface.name ~= 'nauvis' then return end

  local fissures = event.surface.find_entities_filtered{
    area = event.area,
    name = 'se-core-seam-fissure',
  }

  for _, fissure in ipairs(fissures) do
    fissure.destroy()
  end
end

script.on_event(defines.events.on_chunk_generated, on_chunk_generated)

script.on_init(function(event)
  local surface = game.get_surface(1)
  assert(surface)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
  assert(zone.name == 'Nauvis')

  -- local core_miners_on_this_surface = table_size(zone.core_mining)
  -- zone.core_seam_positions

  -- log(serpent.block(zone))

  for _, core_seam_resource in pairs(zone.core_seam_resources) do
    core_seam_resource.fissure.destroy() -- this seals the seam
    core_seam_resource.smoke_generator.destroy() -- weird that sealed seams continue to smoke
  end

  for _, force in pairs(game.forces) do
    for _, chart_tag in ipairs(force.find_chart_tags(surface)) do
      if chart_tag.icon and chart_tag.icon.name == "se-core-seam" then
        chart_tag.destroy()
      end
    end
  end

end)

script.on_event(defines.events.on_chart_tag_added, function(event)
  local tag = event.tag
  if tag.surface.name ~= 'nauvis' then return end

  if tag.icon and tag.icon.name == "se-core-seam" then
    tag.destroy()
  end
end)

local function request_removal()
  script.on_nth_tick(60 * 10, function(event)
    game.print('"se-no-core-fragments-on-nauvis" got uninstalled, please remove the mod.')
  end)
end

script.on_event(defines.events.on_console_chat, function(event)
  if event.message ~= "uninstall se-no-core-fragments-on-nauvis" then return end

  local player = game.get_player(event.player_index)
  assert(player)

  if player.admin == false then player.print('You are not an admin!') end

  global.uninstalled = true
  request_removal()

  local surface = game.get_surface(1)
  assert(surface)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
  assert(zone.name == 'Nauvis')

  for _, core_seam_resource in pairs(zone.core_seam_resources) do
    core_seam_resource.resource.destroy() -- this triggers remove_seam followed by create_seam (effectively restores the smoke)
  end
end)

script.on_load(function(event)
  if global.uninstalled then
    request_removal()
  end
end)
