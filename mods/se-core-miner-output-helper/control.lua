
local function round(number, decimals)
  local multiplier = 10 ^ (decimals or 0)
  return math.floor(number * multiplier + 0.5) / multiplier
end

--

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  local entity = player.selected

  if entity and entity.name == "se-core-miner-drill" and entity.mining_target then

    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
    local core_miners_on_this_surface = table_size(zone.core_mining)
    local fragment_name = entity.mining_target.prototype.mineable_properties.products[1].name
    local fragments_per_second = (entity.prototype.mining_speed / entity.mining_target.prototype.mineable_properties.mining_time) * entity.mining_target.amount / entity.mining_target.prototype.normal_resource_amount

    local text = {}
    text[1] = "[item="..fragment_name.."]"
    text[2] = math.floor(fragments_per_second * 10) / 10 .. "/s"
    text[3] = "+"
    text[4] = entity.force.mining_drill_productivity_bonus * 10 .. "0%"
    text[5] = "x"
    text[6] = core_miners_on_this_surface
    text[7] = "="
    text[8] = "[item="..fragment_name.."]"
    text[9] = round(fragments_per_second * (1 + entity.force.mining_drill_productivity_bonus) * core_miners_on_this_surface, 2) .. "/s"

    player.create_local_flying_text({text = table.concat(text, " "), position = entity.position})
  end

end)
