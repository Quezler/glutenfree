commands.add_command("beacon-interface-selftest", "- Check if the bit modules are able to make up every strength.", function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  if player.admin == false then
    player.print(string.format("[beacon-interface] due to lag only admins may run this."))
    return
  end

  local beacon = player.surface.create_entity{
    name = mod_prefix .. "beacon",
    force = player.force,
    position = player.position,
    raise_built = true,
  }
  assert(beacon)
  local struct = assert(storage.structs[beacon.unit_number], "raise_built?")

  for percentage = shared.min_strength, shared.max_strength do
    Interface.set_effect(beacon.unit_number, "speed", percentage)
    assert_beacon_matches_config(struct)
  end

  beacon.destroy()
  player.print(string.format("[beacon-interface] all %d to %d strengths match.", shared.min_strength, shared.max_strength))
end)
