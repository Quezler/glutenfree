script.on_event(defines.events.on_tick, function(event)
  if not game.surfaces["fulgora"] then return end
  for _, player in ipairs(game.connected_players) do
    player.remove_alert{
      surface = "fulgora"
    }
  end
end)

script.on_event(defines.events.on_entity_damaged, function (event)
  -- local entity = event.entity
  -- if not entity.surface.platform then return end

  if event.source and event.source.type == "asteroid" then
    event.entity.health = event.entity.health + event.final_damage_amount
  end
end, {
  {filter = "damage-type", type = "impact"}
})

local function on_created_tile(event)
  if event.tile.name ~= "space-platform-foundation" then return end

  local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]
  if not surface.platform then return end

  for _, tile_and_position in ipairs(event.tiles) do
    local position = {tile_and_position.position.x + 0.5, tile_and_position.position.y + 0.5}
    local cover = surface.create_entity{
      name = mod_prefix .. "simple-entity",
      force = "neutral",
      position = position,
    }
  end
end

for _, event in ipairs({
  defines.events.on_player_built_tile,
  defines.events.on_robot_built_tile,
  defines.events.on_space_platform_built_tile,
  defines.events.script_raised_set_tiles,
  -- todo: on_area_cloned.clone_tiles
}) do
  script.on_event(event, on_created_tile)
  -- script.on_event(event, on_created_tile, {
  --   {filter = "name", name = "space-platform-foundation"},
  -- })
end
