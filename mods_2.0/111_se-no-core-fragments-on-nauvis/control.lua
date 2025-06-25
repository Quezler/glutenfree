local function get_nauvis()
  local surface = game.get_surface(1)
  assert(surface and surface.name == "nauvis")

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface.index})
  assert(zone and zone.name == "Nauvis")

  return surface, zone
end

local function on_chunk_generated(event)
  if storage.disabled then return end

  local surface = event.surface
  if surface.name ~= "nauvis" then return end

  local _, zone = get_nauvis()

  local chunk_position = event.position
  if zone.core_seam_chunks[chunk_position.x] and zone.core_seam_chunks[chunk_position.x][chunk_position.y] then
    local resource_index = zone.core_seam_chunks[chunk_position.x][chunk_position.y]
    local core_seam_resource = zone.core_seam_resources[resource_index] -- `Unknown key: "1"` on fresh world?

    -- supposedly when a new world generates the seam already got sealed ant thus fissure is nil, not invalid.
    if core_seam_resource.fissure == nil and game.tick == 0 then
      return
    end

    core_seam_resource.fissure.destroy() -- registration_number seals the seam
    core_seam_resource.smoke_generator.destroy()
  end

end

script.on_event(defines.events.on_chunk_generated, on_chunk_generated)

local function enable()
  local surface, zone = get_nauvis()

  local spill_positions = {}
  for _, core_miner in pairs(zone.core_mining) do
    table.insert(spill_positions, core_miner.position)
    core_miner.drill.destroy()
  end

  if zone.core_seam_resources == nil then
    if surface.map_gen_settings.width == 50 and surface.map_gen_settings.height == 50 then
      return
    end
  end

  for _, core_seam_resource in pairs(zone.core_seam_resources) do
    core_seam_resource.fissure.destroy() -- registration_number seals the seam
    core_seam_resource.smoke_generator.destroy()
  end

  for _, spill_position in ipairs(spill_positions) do
    surface.spill_item_stack{
      position = spill_position,
      stack = "se-core-miner",
      enable_looted = true,
      force = "player",
      allow_belts = false,
    }
  end

  for _, force in pairs(game.forces) do
    for _, chart_tag in ipairs(force.find_chart_tags(surface)) do
      if chart_tag.icon and chart_tag.icon.name == "se-core-seam" then
        chart_tag.destroy()
      end
    end
  end

end

local function disable()
  local surface, zone = get_nauvis()

  for _, core_seam_resource in pairs(zone.core_seam_resources) do
    core_seam_resource.resource.destroy() -- registration_number removes and recreates the seam
  end

  local force = game.forces["player"]

  -- instead of doing it the sensible way we'll trigger on_chunk_charted and let SE recreate any/all map tags :3
  for x, ys in pairs(zone.core_seam_chunks) do
    for y, resource_index in pairs(ys) do
      local chunk_position = {x, y}
      if force.is_chunk_charted(surface, chunk_position) then
        force.unchart_chunk(chunk_position, surface)
        force.chart(surface, {{x * 32, y * 32}, {x * 32, y * 32}}) -- why this doesn't accept chunk coords is beyond me
      end
    end
  end

end

script.on_init(function(event)
  enable()
end)

script.on_event(defines.events.on_chart_tag_added, function(event)
  if storage.disabled then return end

  local chart_tag = event.tag
  if chart_tag.surface.name ~= "nauvis" then return end

  if chart_tag.icon and chart_tag.icon.name == "se-core-seam" then
    chart_tag.destroy()
  end

end)

commands.add_command("se-no-core-fragments-on-nauvis", nil, function(command)
  local player = game.get_player(command.player_index)
  assert(player)

  if command.parameter == nil then
    return player.print("/se-no-core-fragments-on-nauvis <enable/disable>")
  end

  if player.admin == false then
    return player.print("You are not an admin!")
  end

  if command.parameter == "enable" then
    if storage.disabled == nil then
      return player.print("Already enabled.")
    else
      storage.disabled = nil
      enable()
    end
  end

  if command.parameter == "disable" then
    if storage.disabled then
      return player.print("Already disabled.")
    else
      storage.disabled = true
      disable()
    end
  end

end)
